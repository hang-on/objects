// Print meta data of given image to the console.
// In: Image filename as a command line argument.
// Example syntax in cmd: node tools/printMetadata gfx/bird.png

const sharp = require("sharp");
const inFile = process.argv[2];

async function printMetadata() {
  try {
    const metadata = await sharp(inFile).metadata();
    console.log(metadata);
  } catch (error) {
    console.log(`${error}`);
  }
}

printMetadata();