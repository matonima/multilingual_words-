# Pronunciation audit

The bundled clips use the written native word wherever a matching native-script
voice is available. Arabic and Russian therefore remain native-text prompts.

## Sanskrit

Sanskrit words now go to the Indic voice in Devanagari instead of an English
voice reading hyphenated hints. This preserves conjuncts: `अग्नि` is `agni`
(`/ɐɡ.n̪i/`), not “ajinee”. Child-facing guides remain approximate and are not
used as synthesis instructions.

Reference rules: Devanagari consonant conjuncts remain joined; vowel length is
preserved; aspirated and retroflex letters remain distinct. Sources checked:

- [Cologne Digital Sanskrit Dictionaries](https://www.sanskrit-lexicon.uni-koeln.de/) / Monier-Williams headwords
- [Sanskrit `अग्नि` Classical IPA](https://en.wiktionary.org/wiki/%E0%A4%85%E0%A4%97%E0%A5%8D%E0%A4%A8%E0%A4%BF)

## Latin

Latin speech prompts are lowercase and continuous so the voice cannot interpret
capitalized guide syllables as spelled letters. `aqua` uses the common English
dictionary pronunciation `/ˈæk.wə/` (“AK-wuh”), per the requested learning
style. Other prompts retain the supplied beginner Classical-style values.

Sources checked:

- [Cambridge Dictionary English pronunciation for *aqua*](https://dictionary.cambridge.org/pronunciation/english/aqua)
- [Lewis and Short Latin Dictionary headword for *aqua*](https://atlas.perseus.tufts.edu/dictionaries/entry/urn%3Acite2%3Ascaife-viewer%3Adictionary-entries.atlas_v1%3Alat.ls.perseus-eng2-n3259/)

Synthetic speech still benefits from review by fluent educators before a large
public classroom rollout.
