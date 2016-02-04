(ns tdb.core
	(:require [lanterna.screen :as s]
		      [clojure.java.jdbc :refer :all]
		      [clj-yaml.core :as yaml]))

(def scr (s/get-screen :swing))

(s/start scr)
(s/get-key-blocking scr)
(s/stop scr)

(def dbh
	{:classname "org.sqlite.JDBC"
	:subprotocol "sqlite"
	:subname "database.db"})

(defn create-db []
	(try (db-do-commands dbh
		(create-table-ddl :news
			[:date :text]
			[:url :text]
			[:title :text]
			[:body :text]))
	(catch Exception e (println e))))

(defn -main [& args]
	(create-db)
	(println "done"))