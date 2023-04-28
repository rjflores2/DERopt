function [optimizationRecordings] = LoadPlaygroundResults(results_path)

    load(results_path, "rec");

    optimizationRecordings = rec;

end