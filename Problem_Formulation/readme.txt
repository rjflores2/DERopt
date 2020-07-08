Description of files:
Initialization & execution files
-opt_var_cf.m-		Initializes variables and generates the cost function. Constrain files used the variables declared in this file
-opt.m- 		File that 1) determines optimization settings, 2) introduces boundary constraints, 3) exports model from yalmip to optimize via matlab command line entry, 4) or optimizes through yalmip

Constraint files arranged alphabetically
-opt_DLPF.m- 		Electrical infrastructure constraints using the "Decoupled Linearized Power Flow"
-opt_ees.m-		Electrical energy storage (ees) constraints - min/max SOC, max charge/discharge
-opt_gen_equalities.m-	General equalities, including energy balances	
-opt_gen_inequalities.m-General inequalities, inclluding demand charges
-opt_LinDistFlow.m-	Electrical infrastructure constraints using "LinDisFlow" formulation
-opt_nem.m-		Net energy metering constraints. Also includes import limits and an extra constraint to introduce islanding
-opt_pv.m-		Solar PV constraints that split solar PV production between products and based on available space
-opt_roof.m-		Additional form to constraint solar area based on roof area - likely to be removed in future versions
-opt_transformers.m-	Transformer constraints developed by LDN

