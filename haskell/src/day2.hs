{-# LANGUAGE QuasiQuotes #-}

module Day2 where

import Data.List.Split (splitOn)
import Text.RawString.QQ (r)

test :: String
test =
  [r|forward 5
down 5
forward 8
up 3
down 8
forward 2|]

type Position = (,,) Int Int Int

part1 :: String -> Int
part1 = solve mover1

mover1 :: Char -> Int -> Position -> Position
mover1 'f' x (a, y, z) = (a, y + x, z)
mover1 'u' x (a, y, z) = (a, y, z - x)
mover1 _d x (a, y, z) = (a, y, z + x)

part2 :: String -> Int
part2 = solve mover2

mover2 :: Char -> Int -> Position -> Position
mover2 'f' x (a, y, z) = (a, y + x, z + (a * x))
mover2 'u' x (a, y, z) = (a - x, y, z)
mover2 _d x (a, y, z) = (a + x, y, z)

solve :: (Char -> Int -> Position -> Position) -> String -> Int
solve fun = calculateTotal . move fun . parse

move :: (Char -> Int -> Position -> Position) -> [(Char, Int)] -> Position
move fun = foldl (\z (x, y) -> fun x y z) (0, 0, 0)

calculateTotal :: Position -> Int
calculateTotal (_, y, z) = y * z

parse :: String -> [(Char, Int)]
parse = fmap parse_line . lines
  where
    parse_line = parse_cmd . splitOn " "
    parse_cmd cmd = (head . head $ cmd, read . last $ cmd :: Int)

main = do
  input <- readFile "../input/day_2.txt"
  return $ part2 input
