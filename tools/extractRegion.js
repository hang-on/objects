// In: Image filename as a command line argument.

const sharp = require("sharp");
const inFile = process.argv[2];
const outFile = process.argv[3];

async function extractRegion(sourceFile, destinationFile) {
  sharp(sourceFile)
    .extract({ left: 0, top: 0, width: 16, height: 16 })
    .toFormat ('png')
    .toFile("mySlice.png", function(err) {
  // console.log(metadata);
  });
};
extractRegion(inFile);