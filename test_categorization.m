




%8. list out top 10 results

for i=1:20
	fullfilelist(min_indexes(i)).name
end

top_image = list_by_top(fullfilelist(min_indexes(1)).name);
top_count = list_by_count( fullfilelist(min_indexes(1:20)));
top_sim = list_by_similarity(sim_distances(1:20), fullfilelist(min_indexes(1:20)) );
keyboard;

