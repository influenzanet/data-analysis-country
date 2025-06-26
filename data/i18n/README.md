# Translation files

Translation files provides human readable text for all texts used in graphics (or reports)

They all have the same format : a single json object associating a key (translation key used in the program) and
the translation as the value.

The files are named using the pattern 'name.language.json' where name is only to organize translation and language
the language code to be loaded.

Translations are done using the `i18n()` function which translate the key(s) passed as parameter(s). If key is not found 
in translation set then the key is returned.