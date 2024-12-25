# Simulation of Source Coding and Channel Coding for a Simple Audio System over a Binary Symmetric Channel
This project aims to simulate a simple audio system communication system over a binary symmetric channel (BSC). The system includes a source coding stage (i.e., a Huffman encoding), and a channel coding stage (i.e., a convolutional coing). The project is divided into two stages:
-Stage 1: Constructing a Huffman code for the provided audio file, comparing the size of the encoded representation before and after applying the Huffman code in addition to comparing it to the entropy of the audio file.
-Stage 2: Simulating the BSC errors, identify the maximum value of the flip probability that results in an acceptable audio quality, operating the MATLAB built-in convolutional encoder to investigate the effect of channel coding on the received audio quality. 

# Stage 1: Constructing a Huffman Code of the Audio File
We aim at constructing a Huffman code for the accompanied audio file according to the following block diagram:
A viable code of the Huffman code.
Plotting the PMF of the symbols within the file.
The resultant Huffman dictionary.
Verification that the decoder of Huffman code can perfectly reconstructs the file without noise.
Calculation of the entropy of the audio file.
Calculation of the compression ratio.

# Stage 2: Binary Symmetric Channel Effect and Convolutional Encoder
In stage 2, we aim to observe of bit errors in the encoded Huffman sequence on the audio quality of the file. We use convolutional encoder to reduce the effect of bit errors on audio quality. 
Explanation of the BSC generation method.
Clarification of the options you used to implement the convolutional encoder and decoder.
The audio file corresponding to uncoded transmission at 
The maximum value of flip error probability that results in acceptable audio quality for uncoded transmission.
The audio file corresponding to coded transmission at 
The maximum value of flip error probability that results in acceptable audio quality for coded transmission.


