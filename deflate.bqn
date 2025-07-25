LEint←{𝕊𝕩:×⟜256⊸+˜´𝕩;𝕨𝕊⁼𝕩:256|>⌊∘÷`((𝕨⊣4)⥊256)»˜𝕩}
isPure←0⊣∊⟜⟨0,1,6⟩∘•Type◶⟨
   ⊑
   ⊢
   {𝕩.pure}⎊0
   !∘"Invalid •args"
   ⟩ •args


deflate⇐isPure⊑⟨
   {crc‿size𝕊data:
      code‿stdout‿stderr←@⊸+⍟(@>·⊑1⊸↑)¨⌾(1‿2⊸⊏){ # cbqn vs dbqn raw mode fix
         raw⇐1
         stdin⇐inp⇐∾⟨
           ⟨
              31,139 # magic
              8 # compression method
              0 # flags
              0,0,0,0 # unix time
              0 # extra flags / deflate flags
              0 # OS (255=unknown,0=default/FAT)
              ⟩
           -⟜@ data
           LEint⁼ crc
           LEint⁼ size
           ⟩
      }•SH"gzip"‿"-d"
      stderr!0=code
      stdout
   }
   {𝕊𝕩:
      !"NYIError:"
   }
   ⟩
