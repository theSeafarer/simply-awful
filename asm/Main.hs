module Main where

import           Text.Read                   ( readMaybe )
import           Data.List                   ( intersperse, init )
import           Control.Monad               ( join )
import           Data.Coerce                 ( coerce )
import           System.Environment          ( getArgs )
import           Numeric

main :: IO ()
main = do
  args <- getArgs
  if length args /= 1
    then putStrLn "wrong arguments!"
    else do
      let fileName = head args
      asm <- readFile fileName
      let res = parse asm
      case res of
        Left e -> print e
        Right ins -> do
          let out = assemble ins
          writeFile "instr_mem.vhd" out
          putStrLn "done!"
  

data Reg = R0 | R1 | R2 | R3 deriving (Show, Eq, Ord, Enum)

newtype Value = MkValue Int deriving (Eq, Ord)

instance Show Value where
  show = showBinWithPadding 6 . coerce

v :: Int -> Maybe Value
v i = 
  if i <= 63
    then Just $ MkValue i
    else Nothing

r :: String -> Maybe Reg
r "R0" = Just R0
r "R1" = Just R1
r "R2" = Just R2
r "R3" = Just R3
r _    = Nothing

showBin :: Int -> String
showBin i = showIntAtBase 2 toC i ""
  where toC 0 = '0'
        toC 1 = '1'

showBinWithPadding :: Int -> Int -> String
showBinWithPadding padding i =
  let bin = showBin i
      rm  = padding - (length bin)
  in  if rm > 0
        then (replicate rm '0') <> bin
        else bin

regId :: Reg -> String
regId = showBinWithPadding 2 . fromEnum

data Instr
  = Load Reg Value
  | Add Reg Reg
  | Sub Reg Reg
  | Jnz Reg Value
  deriving (Show, Eq)

data Err = MkErr Int

instance Show Err where
  show (MkErr no) = "Error in input at line " <> show no

-- this is an abomination
parse :: String -> Either Err [Instr]
parse = sequence . fmap proc . zip [1..] . lines
  where
    proc :: (Int, String) -> Either Err Instr
    proc (lineNo, line) = 
      case proc' of
        Nothing  -> Left $ MkErr lineNo
        Just ins -> Right ins
        where 
          proc' =
            let [ins, arg1', arg2] = words line
                arg1 = init arg1' -- stupid hack
            in case ins of
              "LOAD" -> do
                rx <- r arg1
                val <- v =<< readMaybe arg2
                pure $ Load rx val
              "ADD" -> do
                rx1 <- r arg1
                rx2 <- r arg2
                pure $ Add rx1 rx2
              "SUB" -> do
                rx1 <- r arg1
                rx2 <- r arg2
                pure $ Sub rx1 rx2
              "JNZ" -> do
                rx <- r arg1
                addr <- v =<< readMaybe arg2
                pure $ Jnz rx addr
    
assemble :: [Instr] -> String
assemble = linesToDone . zipWith (<>) (fmap intToMAdd [0..]) . join . fmap assemble'
  where
    assemble' :: Instr -> [String]
    assemble' (Load r v ) = [ "b\"00" <> regId r  <> "00\";"
                            , "b\""   <> show v <> "\";"
                            ]
    assemble' (Add ra rb) = [ "b\"01" <> regId ra <> regId rb <> "\";" ]
    assemble' (Sub ra rb) = [ "b\"10" <> regId ra <> regId rb <> "\";" ]
    assemble' (Jnz r  a ) = [ "b\"11" <> regId r  <> "00\";"
                            , "b\""   <> show a   <> "\";"
                            ]

    intToMAdd :: Int -> String
    intToMAdd i = "mem(" <> show i <> ") <= "

    linesToDone :: [String] -> String
    linesToDone lines = template (length lines) (unlines lines)

    template :: Int -> String -> String
    template lines rom = 
        "library ieee;\n"
      <> "use ieee.std_logic_1164.all;\n"
      <> "use ieee.numeric_std.all;\n"
        
      <> "entity instr_mem is\n"
      <> "   port (\n"
      <> "       addr : in std_logic_vector(5 downto 0);\n"
      <> "       data : out std_logic_vector(5 downto 0)\n"
      <> "   );\n"
      <> "end instr_mem;\n"
        
      <> "architecture instr_mem of instr_mem is\n"
      <> "  type mem_t is array(0 to "<> show (lines - 1) <> ") of std_logic_vector(5 downto 0);\n"
      <> "    signal mem : mem_t;\n"
      <> "begin\n"
      <> "    data <= mem(to_integer(unsigned(addr)));\n"
      <> rom
      <> "\nend instr_mem;"