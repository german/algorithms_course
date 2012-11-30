import System.IO
import Data.List.Split
import qualified Data.Map as Map
import Data.Char

main = do
  handle <- openFile "test.txt" ReadMode  
  contents <- hGetContents handle

  let line = filterLine $ splitOn " " (head (splitOn "\n" contents))
  let map = Map.insert (head line) (tail line) Map.empty
  putStrLn $ show $ map

  let final_map = insertContentsToMap contents
  putStrLn contents
  putStrLn $ show $ final_map

insertLinesToMap :: [String] -> Map.Map String [String] -> Map.Map String [String]
insertLinesToMap [] map = map
insertLinesToMap (line:xs) map =
  insertLinesToMap xs (Map.insertWith (++) (head splittedLine) (tail splittedLine) map)
  where 
    splittedLine = filterLine(splitOn " " line)

filterDigit :: [Char] -> [Char]
filterDigit str = filter (\char -> isDigit char) str

filterLine :: [String] -> [String]
filterLine arr = filter (\str -> length str /= 0) arr

insertContentsToMap :: String -> Map.Map String [String]
insertContentsToMap contents =
  insertLinesToMap (splitOn "\n" contents) Map.empty
