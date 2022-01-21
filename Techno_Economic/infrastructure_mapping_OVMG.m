%% Which Transfomer Each Building Belongs To
xfmr_map = [];
%%%Transformers at each building
for ii = 1:length(bldg)
    xfmr_map{ii,1} = char(bldg(ii).xfmr);
end
% %%%Cutting down transformers to buildings that are examined
% if ~isempty(bldg_ind)
%     xfmr_map = xfmr_map(bldg_ind);
% end

%%%Current transformers
xfmrs_unique = unique(xfmr_map);

%% Transformer data
%%%Pulling transformer Data
xfmr_tbl = readtable('xfmr_ratings.xlsx');
%%%Transformer ratings (kVa)
t_rating = [];
t_map = zeros(length(bldg_base),1);

for ii = 1:length(xfmrs_unique)
    t_map(find(strcmp(xfmrs_unique(ii),xfmr_map))) = ii; %%%Values in this vector are the index in the unique transfomer array that are applicable to the building column
    t_rating(ii,1) = xfmr_tbl.Rating_kVA_(find(strcmp(xfmrs_unique(ii),xfmr_tbl.Name)));
    
end