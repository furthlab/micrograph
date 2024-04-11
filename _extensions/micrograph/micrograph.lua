function micrograph(args, kwargs, meta)
    cmt = meta['show_comments']
        local src = args[1] or ''
        local channelOne = args[2] or 'DAPI'
        local channelTwo = args[3] or 'Phalloidin'
        local channelThree = args[4] or 'Alexa647'
        local imgWidth = pandoc.utils.stringify(kwargs["width"]) or '255'
        local imgHeight = pandoc.utils.stringify(kwargs["height"]) or '100%'

        local html = [[
            <div class='container-wrapper'>
                <div class='canvas-container'>
                    <h6 style="color: blue">]] .. channelOne .. [[</h6>
                    <canvas id='redCanvas' width=']] .. imgWidth .. [[' height=']] .. imgHeight .. [['></canvas>
                    <div class='slider-container channelOne-sliders'>
                        <label for='redMax'>Max:</label>
                        <input type='range' id='redMax' min='0' max='255' value='255'>
                        <label for='redMin'>Min:</label>
                        <input type='range' id='redMin' min='0' max='255' value='0'>
                        <label for='redGamma'>Gamma:</label>
                        <input type='range' id='redGamma' min='0.0' max='2.0' step='0.1' value='1.0'>
                        <label for='redGain'>Gain:</label>
                        <input type='range' id='redGain' min='0' max='255' value='0'>
                    </div>
                </div>
                <div class='canvas-container'>
                    <h6 style="color: green">]] .. channelTwo .. [[</h6>
                    <canvas id='greenCanvas' width=']] .. imgWidth .. [[' height=']] .. imgHeight .. [['></canvas>
                    <div class='slider-container channelTwo-sliders'>
                        <label for='greenMax'>Max:</label>
                        <input type='range' id='greenMax' min='0' max='255' value='255'>
                        <label for='greenMin'>Min:</label>
                        <input type='range' id='greenMin' min='0' max='255' value='0'>
                        <label for='greenGamma'>Gamma:</label>
                        <input type='range' id='greenGamma' min='0.0' max='2.0' step='0.1' value='1.0'>
                        <label for='greenGain'>Gain:</label>
                        <input type='range' id='greenGain' min='0' max='255' value='0'>
                    </div>
                </div>
                <div class='canvas-container'>
                    <h6 style="color: red">]] .. channelThree .. [[</h6>
                    <canvas id='blueCanvas' width=']] .. imgWidth .. [[' height=']] .. imgHeight .. [['></canvas>
                    <div class='slider-container channelThree-sliders'>
                        <label for='blueMax'>Max:</label>
                        <input type='range' id='blueMax' min='0' max='255' value='255'>
                        <label for='blueMin'>Min:</label>
                        <input type='range' id='blueMin' min='0' max='255' value='0'>
                        <label for='blueGamma'>Gamma:</label>
                        <input type='range' id='blueGamma' min='0.0' max='2.0' step='0.1' value='1.0'>
                        <label for='blueGain'>Gain:</label>
                        <input type='range' id='blueGain' min='0' max='255' value='0'>
                    </div>
                </div>
                <div class='canvas-container' style='vertical-align: top;'>
                    <h6>Merge</h6>
                    <canvas id='originalCanvas' width=']] .. imgWidth .. [[' height=']] .. imgHeight .. [['></canvas>
                </div>
            </div>

            <style>

                .canvas-container {
                    display: inline-block;
                    width: ]] .. imgWidth .. [[px; /* Adjust as needed */
                    height: auto; /* Keep aspect ratio */
                    margin-bottom: 20px; /* Adjust vertical spacing between canvas containers */
                }

                .canvas-container canvas {
                    max-width: 100%;
                    height: auto;
                    border-radius: 10px;
                }

                .slider-container {
                    display: block;
                    line-height: 0.5;
                }
                
                .slider-container label {
                    display: block;
                    text-align: left;
                    font-size: small;
                    margin-bottom: 5px; /* Adjust vertical spacing between labels */
                }
                
                .slider-container input[type='range'] {
                    width: calc(100%);
                    margin: 0 auto;
                    margin-bottom: 5px; /* Adjust vertical spacing between input and label */
                }
                
                /* Adjust the color of the slider thumb for green sliders */
                .channelOne-sliders::-webkit-slider-thumb {
                    background-color: blue; /* Change the color as desired */
                }
                
            </style>
            <script src="https://docs.opencv.org/master/opencv.js"></script>
            <script>
                // Function to split image channels
                function splitChannels(image) {
                    const dst = new cv.MatVector();
                    cv.split(image, dst);
                    const [b, g, r] = [dst.get(0), dst.get(1), dst.get(2)];
                    return [r, g, b];
                }

                // Create canvas elements and contexts
                const redCanvas = document.getElementById('redCanvas');
                const redCtx = redCanvas.getContext('2d');
                const greenCanvas = document.getElementById('greenCanvas');
                const greenCtx = greenCanvas.getContext('2d');
                const blueCanvas = document.getElementById('blueCanvas');
                const blueCtx = blueCanvas.getContext('2d');
                const originalCanvas = document.getElementById('originalCanvas');
                const originalCtx = originalCanvas.getContext('2d');

                // Declare variables for channel images
                let redImage, greenImage, blueImage, originalImage;

                // Function to display image on canvas
                function displayImage(ctx, image) {
                    const dst = new cv.Mat();
                    cv.convertScaleAbs(image, dst);

                    // Draw the image directly onto the canvas
                    ctx.canvas.width = dst.cols;
                    ctx.canvas.height = dst.rows;
                    cv.imshow(ctx.canvas, dst);

                    return dst; // Return the created Mat object
                }

                // Function to load and process image
                function processImage() {
                    const imgElement = document.createElement('img');
                    imgElement.onload = () => {
                        const srcMat = cv.imread(imgElement);
                        const [redChannel, greenChannel, blueChannel] = splitChannels(srcMat);
                        
                        // Store original images
                        let originalRed = redChannel.clone();
                        let originalGreen = greenChannel.clone();
                        let originalBlue = blueChannel.clone();

                        // Display red channel
                        redImage = displayImage(redCtx, originalRed);

                        // Display green channel
                        greenImage = displayImage(greenCtx, originalGreen);

                        // Display blue channel
                        blueImage = displayImage(blueCtx, originalBlue);

                        // Display original image
                        originalImage = displayImage(originalCtx, srcMat);

                        // Sliders for adjusting brightness, contrast, gamma, and gain
                        function updateRedChannel() {
                            const max = parseInt(document.getElementById('redMax').value);
                            const min = parseInt(document.getElementById('redMin').value);
                            const gamma = parseFloat(document.getElementById('redGamma').value);
                            const gain = parseInt(document.getElementById('redGain').value);
                            adjustBrightnessContrast(redImage, originalRed, min, max, gamma, gain);
                            cv.imshow(redCanvas, redImage);
                            updateOriginalImage();
                        }

                        function updateGreenChannel() {
                            const max = parseInt(document.getElementById('greenMax').value);
                            const min = parseInt(document.getElementById('greenMin').value);
                            const gamma = parseFloat(document.getElementById('greenGamma').value);
                            const gain = parseInt(document.getElementById('greenGain').value);
                            adjustBrightnessContrast(greenImage, originalGreen, min, max, gamma, gain);
                            cv.imshow(greenCanvas, greenImage);
                            updateOriginalImage();
                        }

                        function updateBlueChannel() {
                            const max = parseInt(document.getElementById('blueMax').value);
                            const min = parseInt(document.getElementById('blueMin').value);
                            const gamma = parseFloat(document.getElementById('blueGamma').value);
                            const gain = parseInt(document.getElementById('blueGain').value);
                            adjustBrightnessContrast(blueImage, originalBlue, min, max, gamma, gain);
                            cv.imshow(blueCanvas, blueImage);
                            updateOriginalImage();
                        }

                        function updateOriginalImage() {
                            const mergedChannels = new cv.MatVector();
                            mergedChannels.push_back(blueImage);
                            mergedChannels.push_back(greenImage);
                            mergedChannels.push_back(redImage);
                            cv.merge(mergedChannels, originalImage);
                            displayImage(originalCtx, originalImage);
                            mergedChannels.delete();
                        }

                        document.getElementById('redMax').addEventListener('input', updateRedChannel);
                        document.getElementById('redMin').addEventListener('input', updateRedChannel);
                        document.getElementById('redGamma').addEventListener('input', updateRedChannel);
                        document.getElementById('redGain').addEventListener('input', updateRedChannel);
                        document.getElementById('greenMax').addEventListener('input', updateGreenChannel);
                        document.getElementById('greenMin').addEventListener('input', updateGreenChannel);
                        document.getElementById('greenGamma').addEventListener('input', updateGreenChannel);
                        document.getElementById('greenGain').addEventListener('input', updateGreenChannel);
                        document.getElementById('blueMax').addEventListener('input', updateBlueChannel);
                        document.getElementById('blueMin').addEventListener('input', updateBlueChannel);
                        document.getElementById('blueGamma').addEventListener('input', updateBlueChannel);
                        document.getElementById('blueGain').addEventListener('input', updateBlueChannel);
                    };
                    imgElement.src = ']] .. src .. [['; // Set image source dynamically
                }

                // Function to adjust brightness and contrast using LUT with gamma correction
                function adjustBrightnessContrast(image, originalImage, min, max, gamma, gain) {
                    const lut = new cv.Mat(256, 1, cv.CV_8U);
                    for (let i = 0; i < 256; i++) {
                        let newValue = Math.pow((i - min) * 1.0 / (max - min), gamma) * 255 + gain;
                        lut.data[i] = Math.min(Math.max(newValue, 0), 255);
                    }
                    cv.LUT(originalImage, lut, image);
                    lut.delete();
                }

                // Call the processImage function when the page loads
                window.onload = processImage;
            </script>
        ]]
        return pandoc.RawBlock('html', html)
end
