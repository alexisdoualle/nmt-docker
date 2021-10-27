/**
 * (Rudimentary implementation)
 * Reduces the size of a txt training corpus by searching for keywords and removing all sentences without at least one of them
 * 
 * Example: using Paracrawl data, which takes bilingual content from the entire web, 
 * only keep sentences relevant to what the engine is used for (ie, no need for politics when training for a fashion e-commerce site).
 * Paracrawl can have many millions of sentences, and most will never be used to train a single engine in a reasonable time
 * 
 * Use a list of most used words from a relevant source and add it below
 * 
 * TODO: A better implementation would use Word Embeddings to look for relevent content 
 */
fs = require('fs');
const { exec, execSync } = require("child_process");
const { write } = require('fs');
const readline = require('readline');

let stopWords = [];
let sourceDirectory = 'data_to_extract/';
let targetDirectory = 'extracted_data/';

// stopWords = fs.readFileSync(sourceDirectory + 'stopwords', 'utf8').split(/\n/gm);

// const readInterface = readline.createInterface({
//     input: fs.createReadStream(sourceDirectory + 'exportSegmentsInternetStores.txt'),
//     console: false
// });

const readInterfaceCorpus = readline.createInterface({
    input: fs.createReadStream(sourceDirectory + 'en-fi.txt'),
    console: false
});

// let allWords = {};
let linesRead = 0;
let linesWritten = 0;

// readInterface.on('line', function(line) {
//     let words = line.replace(/[\(\)\.\/\\\'\"\,\?\!\;\:\“\&\u00D8]/gm, '').toLowerCase().split(' ').map(x => x.toLowerCase());
//     for (word of words) {
//         word = word;
//         if (stopWords.includes(word) || parseInt(word)) continue;
//         allWords[word] ? allWords[word] += 1 : allWords[word] = 1;
//     }
// });

// readInterface.on('close', () => {
//     console.log(Object.entries(allWords).sort((a, b) => b[1] - a[1]));
//     fs.appendFileSync(targetDirectory+'exportSegmentsInternetStoresWords.log', 
//                         Object.entries(allWords).sort((a, b) => b[1] - a[1]).map(x => x).filter(x => x[0]).join('\n'));
// })

readInterfaceCorpus.on('line', function(line) {
    // for (word of Object.entries(allWords).sort((a, b) => b[1] - a[1])) {
    for (let word of wordsToFind) {
        let lineSplit = line.split(/\t/);
        if (lineSplit[0].toLowerCase().indexOf(word) > -1) {
            fs.appendFileSync(targetDirectory+'exportSegmentsInternetStores.en', lineSplit[0] + '\n');
            fs.appendFileSync(targetDirectory+'exportSegmentsInternetStores.fi', lineSplit[1] + '\n');
            
            linesWritten++;
            if (linesWritten%10000 === 0) console.log(linesWritten + " lines WRITTEN to target file");
            break;
        }
    }
    linesRead++;
    if (linesRead%100000 === 0) console.log(linesRead + " lines read from source file");
});
let wordsToFind = [
'bike',
'shimano',
'helmet',
'disc',
'frame',
'chain',
'aluminium',
'brake',
'handlebar',
'grip',
'road',
'lock',
'wheel',
'trail',
'cable',
'riding',
'mountain',
'high-quality',
'cycling',
'rubber',
'carbon',
'e-bike',
'pedal',
'polyester',
'tyre',
'suspension',
'racing',
'handle',
'derailleur',
'sporty',
'schwalbe',
'waterproof',
'elastane',
'composite',
'cyclists',
'breathability',
'shift',
'washable',
'dynamo',
'polyurethane',
'transmission',
'high-performance'
]