{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE TemplateHaskell #-}

import Text.Pandoc
import Text.Pandoc.PDF
import Text.Pandoc.Templates
import Text.Pandoc.Walk (walk)
import Data.Text (Text, pack, unpack)
import qualified Data.Text.IO as TIO
import System.Random.Shuffle (shuffleM)
import Control.Monad.IO.Class (liftIO)
import Text.DocTemplates.Internal
import qualified Data.Map.Strict as Map
import qualified Data.ByteString as BS
import qualified Data.ByteString.Lazy as LBS
import Shh
import System.Environment
import System.FilePath
import System.Directory
import Control.Monad

load SearchPath ["pandoc", "rm", "sed", "cp"]

-- Function to shuffle headings and add \pause
shuffleHeadings :: Pandoc -> IO Pandoc
shuffleHeadings (Pandoc meta blocks) = do
    shuffledBlocks <- shuffleM $ groupByHeadings blocks
    return $ Pandoc meta (concatMap insertPause shuffledBlocks)

-- Group blocks by headings
groupByHeadings :: [Block] -> [[Block]]
groupByHeadings [] = []
groupByHeadings (b@(Header 1 _ _):bs) = (b : content) : groupByHeadings rest
  where (content, rest) = break isHeader1 bs
groupByHeadings (b:bs) = groupByHeadings bs

isHeader1 :: Block -> Bool
isHeader1 (Text.Pandoc.Header 1 _ _) = True
isHeader1 _ = False

-- Insert \pause before content of each heading
insertPause :: [Block] -> [Block]
insertPause (h:content) = h : RawBlock (Format $ pack "markdown") (pack "\\pause") : content
insertPause bs = bs

-- Main function
main :: IO ()
main = do
    args <- getArgs
    print args
    let
        inDir = args !! 0 :: String
        outDir = args !! 1 :: String
        haskellDir = args !! 2 :: String

    fullInDir <- canonicalizePath inDir
    fullOutDir <- canonicalizePath outDir
    fullHaskellDir <- canonicalizePath haskellDir
    -- Reading Markdown content
    files <- listDirectory fullInDir

    let filepaths = map (fullInDir </>) files
    print filepaths
    let filepathsCleaned = filter (\x -> takeExtension x == ".md") filepaths
    print filepaths

    -- TODO: Another stupid fucking hack
    cp "-r" (inDir </> "figures") fullOutDir

    forM_ filepathsCleaned (createPdf fullOutDir fullHaskellDir)

createPdf :: FilePath -> FilePath -> FilePath -> IO ()
createPdf outDir haskellDir inputPath = do
    fullInPath <- canonicalizePath inputPath
    fullOutDir <- canonicalizePath outDir
    fullHaskellDir <- canonicalizePath haskellDir
    let file = takeFileName inputPath
    let fileName = dropExtension file 
    let outPdfPath = fullOutDir </> addExtension fileName ".pdf"
    let outMdPath = fullOutDir </> addExtension fileName ".md"

    content <- TIO.readFile fullInPath
    currentDir <- getCurrentDirectory
    list <- listDirectory currentDir
    TIO.writeFile (outDir </> "out.log") (pack fullInPath)
    templateFile <- TIO.readFile (haskellDir </> "default.md") 

    -- Parsing Markdown
    let readerOptions = def { readerExtensions = pandocExtensions }
    let pandocRes = runPure $ readMarkdown readerOptions content
    case pandocRes of
        Left err -> putStrLn $ "Error parsing Markdown: " ++ show err
        Right doc -> do
            -- Shuffling Headings and Adding \pause
            transformedDoc <- shuffleHeadings doc

            templateRes :: (Either String (Template Text)) <- compileTemplate "" (templateFile :: Text)
            let template = case templateRes of {
                (Left errMsg) -> Nothing;
                (Right temp) -> Just temp
            }
            print templateRes

            let writerOptions = def { 
                writerExtensions = pandocExtensions,
                writerTemplate = template
            }

            -- Write back to markdown
            let mdRes = runPure $ writeMarkdown writerOptions transformedDoc
            case mdRes of
                Left errMsg -> do
                    putStrLn "Error occurred while creating PDF:"
                    print errMsg  -- Print the error message
                Right md -> TIO.writeFile outMdPath md

            -- Eeeeeew

            -- TODO: Removes the stupid ```{=tex} ... ``` in the header includes
            sed "-i" ":a;N;$!ba;s/header: |\\n[ \\t]*```{=tex}/header: |/g" outMdPath
            sed "-i" ":a;N;$!ba;s/[\\t ]*```\\n---/---/g" outMdPath

            -- Pandoc replaces defined commands by what they are defined to be...
            -- But adds spaces, which breaks everything...
            sed "-i" ":a;N;$!ba;s/\\$\\$ *\\([^ ]\\+\\) *\\$\\$/\\$\\$\\1\\$\\$/g" outMdPath
            sed "-i" ":a;N;$!ba;s/\\$ *\\([^ ]\\+\\) *\\$/\\$\\1\\$/g" outMdPath

            -- MD -> PDF
            -- TODO: Using shell here is unimaginably disgusting, but the makePDF function in
            -- pandocs API is unbelievably complicated. See git history for """working"""
            -- version with makePDF.
            --
            -- Solving this properly might just mitigate the above disgusting
            -- sed commands too...

            -- Need this for images...
            setCurrentDirectory outDir

            pandoc outMdPath 
                "-t" "beamer" 
                "-H" (fullHaskellDir </> "header.tex")
                "-V" "theme=Berlin"
                "-o" outPdfPath
