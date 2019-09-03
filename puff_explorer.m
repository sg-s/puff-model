
%%
% This script launches an interactive explorer which allows you to manipulate
% parameters in this model

close all
clearvars
load fit_data

Model = TwoTubesX;

use_this = 1;

Model.Stimulus = fd(use_this).stimulus;
Model.Response = fd(use_this).response;

Model.manipulate;