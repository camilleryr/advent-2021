{-# LANGUAGE QuasiQuotes #-}

module Day1 where

import Text.RawString.QQ (r)

test :: String
test =
  [r|199
200
208
210
200
207
240
269
260
263|]

part1 :: String -> Int
part1 = countIncreases . parse

part2 :: String -> Int
part2 = countIncreases . groupNums [] . parse
  where
    groupNums acc (x : y : z : rest) = groupNums (x + y + z : acc) (y : z : rest)
    groupNums acc _ = reverse acc

countIncreases :: [Int] -> Int
countIncreases = countIncreases 0
  where
    countIncreases acc (x : y : rest) = if x < y then countIncreases (acc + 1) (y : rest) else countIncreases acc (y : rest)
    countIncreases acc _ = acc

parse :: String -> [Int]
parse = map (\x -> read x :: Int) . lines

main = do
  input <- readFile "../input/day_1.txt"
  return $ part2 input
