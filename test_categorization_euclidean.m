function [ predicted_category ] = test_categorization_euclidean( target_image_name, list_of_images, global_sift_descriptors, num_clusters, method )
%Takes in target image, list of images and 

%%
%0. Read in target image
%%
target_image = imread(target_image_name);
if(size(target_image,3) ~= 1)
    target_image = rgb2gray(target_image);
end

%%
%1. Set variables
%%
[num_images, ~] = size(list_of_images);


%%
%2. find features, descriptors in images and save them into global matrix
%%


global_image_histograms = zeros(num_images, num_clusters);

%3. use k means clustering on matrix
global_sift_descriptors = double(global_sift_descriptors);
[centers, assignments] = vl_kmeans(global_sift_descriptors, num_clusters);

%{
%4. compute histogram vectors for each image
for i=1:numel(list_of_images)
    keyboard;
    image = imread(list_of_images{i,1});
	if(size(image,3) ~= 1)
		image = rgb2gray(image);
	end
	[f,d] = vl_sift(single(image));
    [mins, indexs] = min( (vl_alldist(double(d), centers))');
    indexs = indexs';
    for j=1:size(indexs)
        global_image_histograms(i,indexs(j)) = global_image_histograms(i,indexs(j))  + 1;
    end
end
%}

%5. compute histogram on target_image
current_assignment_index = 1;
for i=1:num_images
    %get number of sift descriptors for current image
    num_of_descriptors = size(list_of_images{i,2});
    current_image_sif_descriptors = list_of_images{i,2};
    [mins, indexs] = min( (vl_alldist(double(current_image_sif_descriptors), centers))');
    current_assignment_index = current_assignment_index + num_of_descriptors;
    indexs = indexs';
    for j=1:size(indexs)
        global_image_histograms(i,indexs(j)) = global_image_histograms(i,indexs(j))  + 1;
    end
end

target_image_histogram = zeros(1, num_clusters);
[tf, td] = vl_sift(single(target_image));
[mins, indexs] = min( (vl_alldist(double(td), centers))');
indexs = indexs';
[num_indices, ~] = size(indexs);

for j=1:num_indices
	target_image_histogram(1, indexs(j)) = target_image_histogram(1, indexs(j)) + 1;
end



%6. normalize both target and global sift histogram vectors

target_image_histogram = target_image_histogram / norm(target_image_histogram);
for i=1:num_images
	global_image_histograms(i,:) = global_image_histograms(i,:) / norm(global_image_histograms(i,:));
end



%7. compare target to each vector, finding min 10 by euclidean distance
list_of_distances = dist2(global_image_histograms, target_image_histogram);

[sim_distances,min_indexes] = sort(list_of_distances, 'ascend');

if strcmp(method, 'top_by_first_image')
    predicted_category = list_by_top(list_of_images{min_indexes(1)});
elseif strcmp(method,'top_by_sim')
    predicted_category = list_by_similarity(sim_distances(1:20), list_of_images(min_indexes(1:20),1) );
elseif strcmp(method,'top_by_count')
     predicted_category = list_by_count( list_of_images(min_indexes(1:20)));
else
    'Invalid method called'
    predicted_category = '';
end

end

