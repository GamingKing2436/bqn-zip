LEint←{𝕊𝕩:×⟜256⊸+˜´𝕩;𝕨𝕊⁼𝕩:256|>⌊∘÷`((𝕨⊣4)⥊256)»˜𝕩}
isPure←(<⁼⟨0,1,6⟩⊐•Type)◶⟨
   ⊑⎊0 # array
   ⊢ # scalar
   {𝕩.pure}⎊0 # namespace
   !∘"Invalid •args"
   ⟩ •args

Unjoin←∾⁼⎊(≠⊸↓⊣⊣⊣⁼⌊○≠↑⊢) # dbqn doesn't support it yet

deflate⇐isPure⊑⟨
   {
      crc‿size𝕊data:
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
      ;crc‿size𝕊⁼data:𝕊⁼data # ignore for now
      ;𝕊⁼data:
      gs←1⊑@⊸+⍟(@>·⊑1⊸↑)¨⌾(1‿2⊸⊏){raw⇐1,stdin⇐inp⇐data}•SH<"gzip" #gzip stream and raw mode fix
      ⟨crc‿size,stream⟩←(LEint˘∘‿4⥊-⟜@)⌾⊑¯8(↑⋈↓)1↓(@+31‿139‿8‿0‿0‿0‿0‿0‿0)Unjoin gs
   }
   {𝕊𝕩:
      !"NYIError:"
   }
   ⟩
