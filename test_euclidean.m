
%%Folder section
directory_1 = 'stegosaurus/';
directory_2 = 'okapi/';
directory_3 = 'crocodile/';
category_list = {directory_1; directory_2; directory_3};
num_directories = size(category_list);

%get all relevant files
for d=1:num_directories
    filelist = dir( [ category_list{d} '*.jpg' ] );
    
    tempfilelist = cell(size(filelist, 1), 1);
    %append category to filename for every file in folder
    for i=1:size(filelist)
        image_name = strcat(category_list{d}, filelist(i).name);
        tempfilelist{i} = image_name;
    end
    if ~exist('fullfilelist', 'var')
        fullfilelist = [tempfilelist];
    else
    
    fullfilelist = [fullfilelist; tempfilelist];
    end
end
num_images = size(fullfilelist, 1);




%%Cluster section
min_num_clusters = 10;
max_num_clusters = 300;




%data structure which will store clusternum, count of results that are true
clusters_map = cell( fix(max_num_clusters / min_num_clusters), 2 );

for i=min_num_clusters:5:max_num_clusters
    num_right = 0;
    for j=1:4:num_images
        current_image = fullfilelist(j);
        current_image = current_image{1};
        correct_category = strsplit(current_image, '/');
        correct_category = correct_category(1);
        if strcmp(correct_category, test_categorization_euclidean(current_image, fullfilelist, i,  'top_by_first_image'))
            num_right = num_right + 1;
        end
        if strcmp(correct_category, test_categorization_euclidean(current_image, fullfilelist, i,  'top_by_sim'))
            num_right = num_right + 1;
        end
        if strcmp(correct_category, test_categorization_euclidean(current_image, fullfilelist, i, 'top_by_count'))
            num_right = num_right + 1;
        end
        j
    end
    clusters_map{i/5,1} = i;
    clusters_map{i/5, 2} = num_right;
    i
end
keyboard;