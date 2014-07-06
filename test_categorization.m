%%dfdfd
directory_1 = 'stegosaurus/';
directory_2 = 'okapi/';
directory_3 = 'crocodile/';
directory_list = [directory_1, directory_2, directory_3];

num_folders = 2;
num_clusters = 180;

%%
%0. Read in target image
%%
target_image_name = 'okapi/image_0005.jpg';

%%
%1. read in images
%%

filelist1 = dir([directory_1 '*.jpg']);
for i=1:numel(filelist1)
	filelist1(i).name = strcat(directory_1, filelist1(i).name);
end

filelist2 = dir([directory_2 '/*.jpg']);
for i=1:numel(filelist2)
	filelist2(i).name = strcat(directory_2, filelist2(i).name);
end

filelist3 = dir([directory_3 '/*.jpg']);
for i=1:numel(filelist3)
	filelist3(i).name = strcat(directory_3, filelist3(i).name);
end

fullfilelist = [filelist1 ; filelist2; filelist3];
[num_images, ~] = size(fullfilelist);

%%
%2. find features, descriptors in images and save them into global matrix
%%

global_sift_descriptors = [];
global_image_histograms = zeros(num_images, num_clusters);
image_sift_indexes = 1;
for i=1:numel(fullfilelist)
	%image_sift_indexes = [image_sift_indexes size(global_sift_descriptors)];
	image = imread(fullfilelist(i).name);
	if size(image,3) ~= 1
		image = rgb2gray(image);
	end
	[f,d] = vl_sift(single(image));
	%add descriptors to global matrix 
	global_sift_descriptors = [global_sift_descriptors d(:,:)];
end

%3. use k means clustering on matrix
global_sift_descriptors = double(global_sift_descriptors);
[centers, assignments] = vl_kmeans(global_sift_descriptors, num_clusters);

%4. compute histogram vectors for each image
for i=1:numel(fullfilelist)
    image = imread(fullfilelist(i).name);
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

%5. compute histogram on target_image
target_image = imread(target_image_name);
if(size(target_image,3) ~= 1)
    target_image = rgb2gray(target_image);
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

%8. list out top 10 results

for i=1:20
	fullfilelist(min_indexes(i)).name
end

top_image = list_by_top(fullfilelist(min_indexes(1)).name);
top_count = list_by_count( fullfilelist(min_indexes(1:20)));
top_sim = list_by_similarity(sim_distances(1:20), fullfilelist(min_indexes(1:20)) );
keyboard;

