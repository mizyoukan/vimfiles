" core.async
syntax keyword clojureCoreAsyncSpecial go-loop async/go-loop
syntax keyword clojureCoreAsyncMacro alt! alt!! go thread async/alt! async/alt!! async/go async/thread
syntax keyword clojureCoreAsyncFunc ->BroadcastingWritePort ->MultiplexingReadPort <! <!! >! >!! admix alts! alts!! broadcast buffer chan close! do-alts dropping-buffer mix mult multiplex onto-chan pipe pipeline pipeline-async pipeline-blocking pub put! sliding-buffer solo-mode spool sub take! tap thread-call timeout to-chan toggle unblocking-buffer? unique unmix unmix-all unsub unsub-all untap untap-all async/->BroadcastingWritePort async/->MultiplexingReadPort async/<! async/<!! async/>! async/>!! async/admix async/alts! async/alts!! async/broadcast async/buffer async/chan async/close! async/do-alts async/dropping-buffer async/filter< async/filter> async/into async/map async/map< async/map> async/mapcat< async/mapcat> async/merge async/mix async/mult async/multiplex async/onto-chan async/partition async/partition-by async/pipe async/pipeline async/pipeline-async async/pipeline-blocking async/pub async/put! async/reduce async/remove< async/remove> async/sliding-buffer async/solo-mode async/split async/spool async/sub async/take async/take! async/tap async/thread-call async/timeout async/to-chan async/toggle async/unblocking-buffer? async/unique async/unmix async/unmix-all async/unsub async/unsub-all async/untap async/untap-all

highlight default link clojureCoreAsyncSpecial clojureSpecial
highlight default link clojureCoreAsyncMacro clojureMacro
highlight default link clojureCoreAsyncFunc clojureFunc

" ClojureScript
syntax keyword clojureScriptFunc clj->js js->clj js-obj enable-console-print!
syntax keyword clojureScriptType js/Array js/Boolean js/Date js/Function js/Iterator js/Number js/Object js/RegExp js/String
syntax keyword clojureScriptMessage js/alert js/confirm js/prompt
syntax keyword clojureScriptObject js/window js/navigator js/screen js/history js/location js/document

highlight default link clojureScriptFunc clojureFunc
highlight default link clojureScriptType clojureRegexpCharClass
highlight default link clojureScriptMessage clojureRegexpCharClass
highlight default link clojureScriptObject clojureRegexpCharClass
