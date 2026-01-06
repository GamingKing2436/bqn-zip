Deflate←(•Import"deflate.bqn").Deflate
LEint←{𝕊𝕩:×⟜256⊸+˜´𝕩;𝕨𝕊⁼𝕩:256|>⌊∘÷`((𝕨⊣4)⥊256)»˜𝕩}

m⇐{⟨cdfh,lfh,eocd,dd⟩⇐@+<˘80‿75∾⎉1∘‿2⥊1+↕8} # magic bytes
field⇐{
   eocd⇐4‿2‿2‿2‿2‿4‿4‿2
   cdfh⇐4‿2‿2‿2‿2‿2‿2‿4‿4‿4‿2‿2‿2‿2‿2‿4‿4
   lfh ⇐4‿  2‿2‿2‿2‿2‿4‿4‿4‿2‿2
   
   cdtl⇐1‿0‿1‿1‿1‿1‿1‿1‿1‿1‿1‿1‿0‿0‿0‿0‿0‿1‿1‿0 # cdfh to lfh bitmap
}


# const⇐{key⇐{
#    eocd⇐{⟨sig,disknum,cddisk,cddiskcount,cdcount,cdsize,cd,commentlen,comment⟩⇐↕9}
#    cdfh⇐{⟨sig,version,minversion,flags,compressiontype,mtime,mdate,crc32,compressedsize,size,namelen,extrafieldlen,commentlen,disk,internalattr,externalattr,fileoffset,name,extrafield,comment⟩⇐↕20}
#    lfh ⇐{⟨sig,       ,minversion,flags,compressiontype,mtime,mdate,crc32,compressedsize,size,namelen,extrafieldlen,                                                    ,name,extrafield,       ⟩⇐↕13}
# }}

EOCD⇐{𝕊𝕩: # End of central directory record
   o←field.eocd/⊸⊔22↑𝕩
   "Error: not a zip file"!m.eocd≡⊑o
   
   (LEint¨-⟜@)⌾(1⊸↓)o
   ;𝕊⁼𝕩: # to write
   ∾(field.eocd +⟜@∘(LEint⁼¨)⌾(1⊸↓) ⊢)⌾(8⊸↑) 𝕩
}
CDFH⇐{𝕊𝕩: # Central directory file header
   o←field.cdfh/⊸⊔46↑𝕩
   "Error: cdfh signature missing"!m.cdfh≡⊑o
   o↩(LEint¨-⟜@)⌾(1⊸↓)o
   ⟨name,extrafield,comment⟩←»⟜""‿""‿""(10‿11‿12⊏o)/⊸(⊣⊔≠⊸↑)46↓𝕩
   
   o∾⟨name,extrafield,comment⟩
   ;𝕊⁼𝕩: # to write
   ∾(field.cdfh +⟜@∘(LEint⁼¨)⌾(1⊸↓) ⊢)⌾(17⊸↑) 𝕩
}
LFH⇐{𝕊𝕩: # Local file header
   o←field.lfh/⊸⊔30↑𝕩
   "Error: lfh signature missing"!m.lfh≡⊑o
   o↩(LEint¨-⟜@)⌾(1⊸↓)o
   ⟨name,extrafield⟩←»⟜""‿""(9‿10⊏o)/⊸(⊣⊔≠⊸↑)30↓𝕩
   o↩o DD˜ ¯16↑𝕩
   
   o∾⟨name,extrafield⟩
   ;𝕊⁼𝕩: # to write
   ∾(field.lfh +⟜@∘(LEint⁼¨)⌾(1⊸↓) ⊢)⌾(11⊸↑) 𝕩
}

DD⇐{𝕨𝕊𝕩: # Data descriptor
   crc32‿compressedsize‿size←6‿7‿8⊏𝕩
   "Error: crc32 is not null when data descriptor present"!0=crc32
   "Error: sizes are not empty when data descriptor present"!∨´∊⟜⟨0,¯1+2⋆32⟩compressedsize‿size
   "NYIError: zip64"∨´(¯1+2⋆32)=compressedsize‿size
   ddfield←⟨4⌾×m.dd≡4↑𝕨,4,4,4⟩
   new←1↓ddfield/⊸⊔(+´ddfield)↑𝕨
   
   new⌾(6‿7‿8⊸⊏)𝕩
}⍟(2⊸|·÷⟜8 2⊑⊢) # check flag

ParseCD⇐{count𝕊𝕩:
   𝕩{𝕩+46+´LEint˘∘‿2⥊𝕨⊏˜(28+↕6)+𝕩}⍟(1+↕count)0
}

FindEOCD⇐(¯1⊑·/m.eocd⍷⊢)

Decompress⇐{ # 𝕨 is compression method, 𝕩 is the compressed data
   𝕊⁼𝕩:Deflate 𝕩
   ;0‿crc‿size𝕊𝕩:𝕩
   ;8‿crc‿size𝕊𝕩: crc‿size Deflate⁼ 𝕩
   ;𝕨𝕊𝕩:!"Error: Unknown compression type: "∾•Repr𝕨
}
Pack⇐{
   𝕊⁼𝕩:
   eocd_bytes←(FindEOCD↓⊢)𝕩
   zi←EOCD eocd_bytes # zip info
   comment←eocd_bytes↑˜-¯1⊑zi
   "NYIError: multipart archive"!0‿0≡1‿2⊏zi # disk number better be 0
   "NYIError: multipart archive"!≡´3‿4⊏zi # every cdfh should be on the same disk
   count‿size‿start←4‿5‿6⊏zi
   cdfhi←size↑start↓𝕩 # cdfh info
   filei←⍉>CDFH¨cdfhi⊔˜+`/⁼count ParseCD -⟜@ cdfhi # file info
   "NYIError: multipart archive"!∧´0=13⊏filei # disk number better be 0
   fcsize‿fsize‿namelen‿exlen‿fstart←<˘8‿9‿10‿11‿16⊏filei
   files←(30+namelen+exlen+fcsize+16)↑¨fstart↓¨<𝕩 # 16 to account for possible data descriptor
   "Error: central directory file header and local file header don't match"!(field.cdtl/filei)≡○(1⊸↓)⍉>LFH¨files # compare filei and lfilei
   filedata←fcsize↑¨(30+namelen+exlen)↓¨files
   
   ⟨comment,filei∾filedata⟩
   ;𝕊comment‿filei:comment𝕊filei
   ;𝕊𝕩:""𝕊𝕩
   ;comment𝕊𝕩:
   files←(¯1⊏𝕩)∾¨˜LFH¨⁼m.lfh⌾⊑¨<˘⍉⁼field.cdtl/¯1↓𝕩
   cdfhis←CDFH¨⁼<˘⍉⁼(+`»≠¨files)⌾(16⊸⊏)¯1↓𝕩 # fix file offsets and unparse
   zi←⟨m.eocd,0,0,≠cdfhis,≠cdfhis,≠∾cdfhis,+´≠¨files,≠comment⟩
   ∾⟨∾files,∾cdfhis,EOCD⁼zi,comment⟩
}
Zip⇐{
   𝕊⁼𝕩:
   comment‿filei←Pack⁼𝕩
   file_contents←((<˘·⍉4‿7‿9⊏⊢) Decompress¨¯1⊸⊏) filei # compressiontype‿crc32‿size
   
   (17⊏filei)≍file_contents
   ;𝕊comment‿filei:comment𝕊filei
   ;𝕊𝕩:""𝕊𝕩
   ;comment𝕊𝕩:
   crc‿size‿data‿compressiontype‿name←<˘ ∾⟜<´⌾(1⊸↑)⍟3˘⌾⍉ (⊢(⊢◶⟨0‿0⊸⋈˜,Decompress⁼∘⊣⟩¨⋈¨8⊸×)'/'≠¯1⊑¨⊣)⌾⊏⟜⌽𝕩
   
   filei←>(1⊸⊑⟜≢𝕩)⥊¨⟨<m.cdfh,0,10,0,compressiontype, 0,0, crc,compressedsize←≠¨data,size,namelen←≠¨name,0,0,0, 0,16∧'/'=¯1⊑¨name,46+namelen+compressedsize, name,<"",<""⟩
   Pack filei∾data
}

dir⇐{
   Bytes⇐{
      𝕊𝕩:
      F←•file.RealPath(•wdpath•file.At𝕩)⊸•file.At
      files←1⊑(⊢(∾⋈˜⊢/˜'d'=•file.Type∘F¨∘⊢)·∾(<•file.At¨•file.List∘F)¨∘⊣)´•_while_(0≢≠∘⊑)⟨""⟩‿⟨⟩
      ⍉>(⊢◶⟨
         ⊣⋈•FBytes∘F∘⊣,
         ∾⟜'/'⋈""˙,
         ⊣⋈¯1↓⍟((@+10)≡⊑)·(!0≡⊑)⊸⊑∘•SH"readlink"⊸⋈⟜F∘⊣, # unused but fully working
      ⟩¨)⟜("fdl"⊸⊐•file.Type∘F¨)files
      ;𝕨𝕊𝕩:
      F←(•wdpath•file.At𝕨)⊸•file.At
      •file.CreateDir⍟(¬•file.Exists)F""
      ∾⟨•file.CreateDir⍟(¬•file.Exists)¨⊣,•FBytes¨⟩<⁼⊸{<𝕎´𝕩}˘⍉(⊢⊔⎉1˜'/'≠¯1⊑¨⊏)F¨⌾⊏𝕩
   }
}

Unpack⇐Pack⁼
Unzip⇐Zip⁼
