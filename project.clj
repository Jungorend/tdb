(defproject tdb "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :dependencies [[org.clojure/clojure "1.7.0"]
                 [clojure-lanterna "0.9.4"]
                 [org.clojure/java.jdbc "0.4.2"]
                 [org.xerial/sqlite-jdbc "3.8.11.2"]
                 [clj-yaml "0.4.0"]]
  :main tdb.core)
