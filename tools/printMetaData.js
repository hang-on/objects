// Print meta data of given image to the console.
// In: Image filename as a command line argument.

const sharp = require("sharp");
const inFile = process.argv[2];

async function getMetadata() {
  try {
    const metadata = await sharp(inFile).metadata();
    console.log(metadata);
  } catch (error) {
    console.log(`${error}`);
  }
}

getMetadata();