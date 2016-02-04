(ns tdb.core
	(:require [lanterna.screen :as s]))

(def scr (s/get-screen :swing))

(s/start scr)
(s/get-key-blocking scr)
(s/stop scr)

(defn -main [& args]
	(println "done"))