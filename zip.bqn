file←•FBytes "/storage/emulated/0/Download_organized/bruh.zip"
LEint←×⟜256⊸+´∘⌽

const⇐{
    key⇐{
        eocd⇐{⟨sig,disknum,cddisk,cddiskcount,cdcount,cdsize,cd,commentlen,comment⟩↕9}
        cdfh⇐{⟨sig,version,minversion,flags,compressiontype,mtime,mdate,crc32,compressedsize,size,namelen,extrafieldlen,commentlen,disk,internalattr,externalattr,fileoffset,name,extrafield,comment⟩⇐↕20}
    }
    keylen⇐{
        eocd⇐4‿2‿2‿2‿2‿4‿4‿2
        cdfh⇐4‿2‿2‿2‿2‿2‿2‿4‿4‿4‿2‿2‿2‿2‿2‿4‿4
    }
}

EOCD⇐{ # End of central directory record
    ⟨sig,disknum,cddisk,cddiskcount,cdcount,cdsize,cd,commentlen⟩⇐(+`/⁼+`4‿2‿2‿2‿2‿4‿4‿2)⊔22↑𝕩
    ⟨disknum,cddisk,cddiskcount,cdcount,cdsize,cd,commentlen⟩↩LEint¨-⟜@⟨disknum,cddisk,cddiskcount,cdcount,cdsize,cd,commentlen⟩
}
CDFH⇐{ # Central directory file header
    ⟨sig,version,minversion,flags,compressiontype,mtime,mdate,crc32,compressedsize,size,namelen,extrafieldlen,commentlen,disk,internalattr,externalattr,fileoffset⟩⇐(+`/⁼+`4‿2‿2‿2‿2‿2‿2‿4‿4‿4‿2‿2‿2‿2‿2‿4‿4)⊔46↑𝕩
    ⟨version,minversion,flags,compressiontype,mtime,mdate,crc32,compressedsize,size,namelen,extrafieldlen,commentlen,disk,internalattr,externalattr,fileoffset⟩↩LEint¨-⟜@⟨version,minversion,flags,compressiontype,mtime,mdate,crc32,compressedsize,size,namelen,extrafieldlen,commentlen,disk,internalattr,externalattr,fileoffset⟩
    ⟨name,extrafield,comment⟩⇐⟨namelen,extrafieldlen,commentlen⟩/⊸(⊣⊔≠⊸↑)46↓𝕩
    len⇐46+´⟨namelen,extrafieldlen,commentlen⟩
}
