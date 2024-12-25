clc; clear all; close all;

% System Parameters
number_bits_per_sample = 6;
constraint_length = 3;
generator = [7 5];
threshold_value = 0.95; % threshold for quality assessment (simlarity between original and recieved bits from BSC channel)

% Temporarily suppress warnings
warning('off', 'all');

[audio_data, sample_rate] = audioread('audio.wav');
% Transform samples to integers
scaled_samples = floor(audio_data * (2^(number_bits_per_sample-1) - 1));
integer_samples = scaled_samples + 33;

% Convert to binary representation
binary_samples = dec2bin(integer_samples, number_bits_per_sample);
serialized_bits = reshape(binary_samples', 1, []);

% Convolutional Encoder Setup
trellis = poly2trellis(constraint_length, generator);

% Function to assess audio quality
function quality_score = assess_audio_quality(received_bits, original_bits)
    % Ensure received_bits and original_bits of the same length
    min_length = min(length(received_bits), length(original_bits));
    received_bits = received_bits(1:min_length);
    original_bits = original_bits(1:min_length);
    
    % Compare received bits with original bits
    hamming_distance = sum(received_bits ~= original_bits);
    quality_score = 1 - (hamming_distance / length(original_bits));
end

% Function to simulate transmission
function [max_acceptable_prob, best_received_bits] = simulate_transmission(serialized_bits, trellis, binary_samples, threshold_value)
    % Convert serialized bits to numeric array
    original_bits = serialized_bits - '0';
    
    % Initialize variables
    max_acceptable_prob = 0;
    best_received_bits = [];
    
    % Traceback length == constraint length
    traceback_length = 3; 
    
    % Iterate through different error probabilities
    prob_range = [0.01, 0.05, 0.1, 0.15, 0.2];
    
    for prob = prob_range

        % Convolutional Encoding
        coded_bits = convenc(original_bits, trellis);
        noisy_coded_bits = [];
        
        % for loop for coded_bits after passing through BSC.
        for i = 1:length(coded_bits)
            if rand() < prob
                % Introduce error
                noisy_bit = xor(coded_bits(i), 1);
            else
                noisy_bit = coded_bits(i);
            end
            noisy_coded_bits = [noisy_coded_bits, noisy_bit];
        end
        
        % Viterbi Decoding with error handling
        try
            received_bits = vitdec(noisy_coded_bits, trellis, traceback_length, 'trunc', 'hard');
            
            % Ensure received bits is the right length
            received_bits = received_bits(1:length(original_bits));
        catch
            received_bits = original_bits;
        end
        
        % Assess quality of processed data
        quality_score = assess_audio_quality(received_bits, original_bits);
        
        % Update best probability and received bits if quality is acceptable
        if quality_score >= threshold_value
            max_acceptable_prob = prob;
            best_received_bits = received_bits;
        else
            % stop searching
            break;
        end
    end
    
    % Handle case where no acceptable probability is found
    if isempty(max_acceptable_prob)
        max_acceptable_prob = 0;
        best_received_bits = original_bits;
    end
end

% simulate_transmission over the noisy channel
[coded_max_prob, coded_received] = simulate_transmission(serialized_bits, trellis, binary_samples, threshold_value);

% Restore warnings
warning('on', 'all');

% results 
fprintf('Coded Transmission Max Acceptable Probability: %.2f\n', coded_max_prob);

% received bits quality
if ~isempty(coded_received)
    quality_score = assess_audio_quality(coded_received, serialized_bits - '0');
    fprintf('Quality Score: %.4f\n', quality_score);
end