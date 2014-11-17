" ClojureScript
syntax keyword clojureScriptFunc clj->js js->clj js-obj enable-console-print!
syntax keyword clojureScriptType js/Array js/Boolean js/Date js/Function js/Iterator js/Number js/Object js/RegExp js/String
syntax keyword clojureScriptMessage js/alert js/confirm js/prompt
syntax keyword clojureScriptObject js/window js/navigator js/screen js/history js/location js/document

highlight default link clojureScriptFunc clojureFunc
highlight default link clojureScriptType clojureRegexpCharClass
highlight default link clojureScriptMessage clojureRegexpCharClass
highlight default link clojureScriptObject clojureRegexpCharClass
