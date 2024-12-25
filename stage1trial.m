clc;
clear all;
close all;

% System Parameters
number_bits_per_sample = 6;

% Read Audio File (Replace with actual audio file path)
[audio_data, sample_rate] = audioread('audio.wav');

% Map samples to integers 1:64
samples = floor(audio_data * (2^(number_bits_per_sample-1) - 1));
integer_samples = samples + 33;

% Convert to binary representation
binary_samples = dec2bin(integer_samples, number_bits_per_sample);
serialized_bits = reshape(binary_samples', 1, []);

% Find Symbol Probabilities
unique_symbols = unique(integer_samples);
symbol_counts = hist(integer_samples, unique_symbols);
pmf = symbol_counts / length(integer_samples);

% Plot PMF
figure;
bar(unique_symbols, pmf);
title('Probability Mass Function of Audio Symbols');
xlabel('Symbol Value');
ylabel('Probability');

% Entropy
entropy = -sum(pmf .* log2(pmf + eps));
fprintf('Entropy of Audio File: %.4f bits\n', entropy);

% Custom Huffman Dictionary Generation Function
function [huffman_codes] = custom_huffman_dict(symbols, probs)
    nodes = struct('symbol', {}, 'prob', {}, 'left', {}, 'right', {}, 'code', {});
    for i = 1:length(symbols)
        nodes(i) = struct('symbol', symbols(i), 'prob', probs(i), ...
                           'left', [], 'right', [], 'code', '');
    end
    
    while length(nodes) > 1
        % Take last two nodes (lowest probabilities)
        [~, idx] = sort([nodes.prob]);
        nodes = nodes(idx);
        left = nodes(1);
        right = nodes(2);
        parent = struct('symbol', [], 'prob', left.prob + right.prob, ...
                        'left', left, 'right', right, 'code', '');
        nodes = [nodes(3:end), parent];
    end
    
    % Recursively generate codes
    function assign_codes(node, current_code)
        if isempty(node.left) && isempty(node.right)
            huffman_codes(num2str(node.symbol)) = current_code;
        else
            assign_codes(node.left, [current_code, '0']);
            assign_codes(node.right, [current_code, '1']);
        end
    end
    
    huffman_codes = containers.Map();
    assign_codes(nodes(1), '');
end

% Custom Huffman Encoding Function
function encoded_bits = custom_huffman_encode(integer_samples, huffman_codes)
    encoded_bits = '';
    for i = 1:length(integer_samples)
        encoded_bits = [encoded_bits, huffman_codes(num2str(integer_samples(i)))];
    end
end

% Custom Huffman Decoding Function
function decoded_symbols = custom_huffman_decode(encoded_bits, huffman_codes)
    decoded_symbols = [];
    current_code = '';
    code_to_symbol = containers.Map(values(huffman_codes), keys(huffman_codes));
    
    for i = 1:length(encoded_bits)
        current_code = [current_code, encoded_bits(i)];
        if isKey(code_to_symbol, current_code)
            decoded_symbols = [decoded_symbols, str2double(code_to_symbol(current_code))];
            current_code = '';
        end
    end
end

% Generate Custom Huffman Dictionary
custom_dict = custom_huffman_dict(unique_symbols, pmf);

% Custom Huffman Encoding
encoded_bits = custom_huffman_encode(integer_samples, custom_dict);
fprintf('Length of Encoded Bits (Custom): %d\n', length(encoded_bits));

% Compression Ratio Calculation for Custom Encoder
original_size = length(serialized_bits);
compressed_size_custom = length(encoded_bits);
compression_ratio_custom = original_size / compressed_size_custom;

% Theoretical Lower Bound Compression Ratio
expected_code_length = sum(pmf .* cellfun('length', values(custom_dict))) * length(integer_samples);
CR_lowerbound = expected_code_length / original_size;

% Decode and Validate
decoded_symbols_custom = custom_huffman_decode(encoded_bits, custom_dict);

% Output Results
fprintf('Compression Ratio (Custom): %.2f\n', compression_ratio_custom);
fprintf('Theoretical Lower Bound Compression Ratio: %.2f\n', CR_lowerbound);

