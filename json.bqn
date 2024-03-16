# parser for relaxed version of json to be used as input for mustache.bqn
# converts json into [parents,,refs]‿names object
# - keys and values do not need quotes
# - all values are strings
# - trailing commas are allowed

Parent ⇐ { g←⊔¯1⌽𝕩 ⋄ (↕≠𝕩) {a‿w←𝕨 ⋄ (⊏⟜a 1-˜a⍋w)⌾(w⊸⊏) 𝕩 }´ (1↓(»g){𝕨‿𝕩}¨g) }
Delete ⇐ { (/¬𝕨)(⊢-⍋)𝕨/𝕩 } # delete from parent vector

⟨
  none,str,col,com,curl_opn,curl_cls,sqr_opn,sqr_cls,quote,      # characters
  key,val,obj,arr,                                                # nodes
⟩←↕13

labels ⇐ " s       kvoa"

# TODO validation with line/col numbers
Parse ⇐ {
    ch ← 𝕩 ⋄ t ← @ ⋄ r←@ ⋄ n ← @ ⋄ p ← @                                                                           # t: es, r:references, n: names
    { ch (¬ch∊(@+10)‿' ')⊸/↩ }                                                                                     # remove whitespace TODO keep line and column numbers 
    { t↩ ∨´⟨curl_opn,curl_cls,sqr_opn,sqr_cls,col,com⟩×ch⊸=¨"{}[]:,"                                             # tokenize characters
      t↩t∨(str×ch∊∾"0aA"+⟜↕¨10‿26‿26) }
    { m←t=str ⋄ f← »⊸< m ⋄ i←m×+`f ⋄ z ←f∨t≠str ⋄ n ↩ ⊏⟜ch¨⊔1-˜i ⋄ ch z⊸/↩ ⋄ t z⊸/↩ ⋄ r ↩ 1-˜z/f×i }               # tokenize strings into reference and name vectors
    { o←(t=curl_opn)∨t=sqr_opn ⋄ c←(t=curl_cls)∨t=sqr_cls ⋄ p↩ Parent +`o-c }                                    # parse parents of brackets (ch no longer needed after tokenizing processes)
    { m←t=col ⋄ s←t=str ⋄ t↩(¬m)/key¨⌾((s∧«m)⊸/)t ⋄ r (¬m)⊸/↩ ⋄ p↩(¬m) Delete p }                                  # parse keys
    { m←(t≠curl_cls)∧(t≠sqr_cls)∧(t≠com) ⋄ t m⊸/↩ ⋄ r m⊸/↩ ⋄ p↩m Delete p }                                       # remove unneeded nodes - closing backets and commas
    { m←t=curl_opn ⋄ t↩t⌈m×obj }                                                                              # mark objects 
    { m←(p⊏p)⊏(t=sqr_opn) 
      •Show m
    #⋄ t↩t⌈m×arr 

    }                                                                              # mark arrays 
    { m←t=str ⋄ t↩t⌈m×val }                                                                                 # mark vals
    { m←»t=key ⋄ p (m/»↕≠p)⌾(m⊸/) ↩ }                                                                              # move object values parent to keys   
    { ptr⇐ [p, ⊢◶labels¨t, r] ⋄  names ⇐ n }
}
