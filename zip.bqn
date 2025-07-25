file⇐•FBytes "/storage/emulated/0/Download/my-keyboard-main.zip"
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
}
CDFH⇐{𝕊𝕩: # Central directory file header
   o←field.cdfh/⊸⊔46↑𝕩
   "Error: cdfh signature missing"!m.cdfh≡⊑o
   o↩(LEint¨-⟜@)⌾(1⊸↓)o
   ⟨name,extrafield,comment⟩←»⟜""‿""‿""(10‿11‿12⊏o)/⊸(⊣⊔≠⊸↑)46↓𝕩
   
   o∾⟨name,extrafield,comment⟩
}
LFH⇐{𝕊𝕩: # Local file header
   o←field.lfh/⊸⊔30↑𝕩
   "Error: lfh signature missing"!m.lfh≡⊑o
   o↩(LEint¨-⟜@)⌾(1⊸↓)o
   ⟨name,extrafield⟩←»⟜""‿""(9‿10⊏o)/⊸(⊣⊔≠⊸↑)30↓𝕩
   o↩o DD˜ ¯16↑𝕩
   
   o∾⟨name,extrafield⟩
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
Decompress⇐{ # 𝕨 is compression method, 𝕩 is the compressed data
   0‿crc‿size𝕊𝕩:𝕩
   ;8‿crc‿size𝕊𝕩: crc‿size Deflate 𝕩
   ;𝕨𝕊𝕩:!"Error: Unknown compression type: "∾•Repr𝕨
}
Main⇐{
   zi←EOCD ¯62↑𝕩 # zip info
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
   file_contents←(<˘⍉4‿7‿9⊏filei) Decompress¨ filedata # compressiontype‿crc32‿size
   ⟨filei,filedata,file_contents⟩⇐
}

