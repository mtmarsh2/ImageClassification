function [ category_list ] = list_by_similarity( distances, images  )

%find best category by summing up the count of images represented by each
%category in the list passed in, then deems the one with the most votes as
%the best

[num_images, ~] = size(images);
category_map = containers.Map();
for i=1:num_images
    
    category = strsplit(images(i).name, '/');
    category = category(1);
    category = category{1};
    if ~isKey(category_map, category)
        category_map(category) = distances(i);
    else
        category_map(category) = category_map(category) + distances(i);
    end
    
  
end

[num_categories, ~] = size(category_map);
category_list = cell(num_categories, 2);
keys_list = keys(category_map);
for i=1:num_categories
    category = keys_list(i);
    category_list{i,1} = category;
    category_list{i,2} = category_map(category{1});
end
category_list = sortrows(category_list, (-2));

end


