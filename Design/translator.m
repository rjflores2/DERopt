clc, clear all
dt1 = load('Sc1_DER_Residential_v2.mat');
dt2 = load('Sc1_DER_CandI_V2.mat');
%% Utility
rec_import = [];
rec_import(:,dt1.bldg_ind) = dt1.import;
rec_import(:,dt2.bldg_ind) = dt2.import;

%% PV

rec_pv_adopt=[];
rec_pv_adopt(:,dt1.bldg_ind) = dt1.pv_adopt;
rec_pv_adopt(:,dt2.bldg_ind) = dt2.pv_adopt;

rec_pv_nem = [];
rec_pv_nem(:,dt1.bldg_ind) = dt1.pv_nem;
rec_pv_nem(:,dt2.bldg_ind) = dt2.pv_nem;

rec_pv_elec = [];
rec_pv_elec(:,dt1.bldg_ind) = dt1.pv_elec;
rec_pv_elec(:,dt2.bldg_ind) = dt2.pv_elec;

%% REES

rec_rees_adopt=[];
rec_rees_adopt(:,dt1.bldg_ind) = dt1.rees_adopt;
rec_rees_adopt(:,dt2.bldg_ind) = dt2.rees_adopt;

rec_rees_dchrg_nem = [];
rec_rees_dchrg_nem(:,dt1.bldg_ind) = dt1.rees_dchrg_nem;
rec_rees_dchrg_nem(:,dt2.bldg_ind) = dt2.rees_dchrg_nem;

rec_rees_chrg = [];
rec_rees_chrg(:,dt1.bldg_ind) = dt1.rees_chrg;
rec_rees_chrg(:,dt2.bldg_ind) = dt2.rees_chrg;

rec_rees_dchrg = [];
rec_rees_dchrg(:,dt1.bldg_ind) = dt1.rees_dchrg;
rec_rees_dchrg(:,dt2.bldg_ind) = dt2.rees_dchrg;

rec_rees_soc = [];
rec_rees_soc(:,dt1.bldg_ind) = dt1.rees_soc;
rec_rees_soc(:,dt2.bldg_ind) = dt2.rees_soc;

%% EES

rec_ees_adopt=[];
rec_ees_adopt(:,dt1.bldg_ind) = dt1.ees_adopt;
rec_ees_adopt(:,dt2.bldg_ind) = dt2.ees_adopt;

rec_ees_chrg = [];
rec_ees_chrg(:,dt1.bldg_ind) = dt1.ees_chrg;
rec_ees_chrg(:,dt2.bldg_ind) = dt2.ees_chrg;

rec_ees_dchrg = [];
rec_ees_dchrg(:,dt1.bldg_ind) = dt1.ees_dchrg;
rec_ees_dchrg(:,dt2.bldg_ind) = dt2.ees_dchrg;

rec_ees_soc = [];
rec_ees_soc(:,dt1.bldg_ind) = dt1.ees_soc;
rec_ees_soc(:,dt2.bldg_ind) = dt2.ees_soc;

%%
pv_v = dt1.pv_v;
ees_v = dt1.ees_v;
cap_mod_o = dt1.cap_mod;
pv_cap = dt1.pv_cap;
ees_cap = dt1.ees_cap;
sgip_o = dt1.sgip_o;
rec_sgip_ees_npbi_equity = zeros(1,length(rec_ees_adopt));
rec_sgip_ees_pbi = zeros(3,length(rec_ees_adopt));
rec_sgip_ees_npbi = zeros(1,length(rec_ees_adopt));

clear dt1 dt2