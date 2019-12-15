# parameters
set S; # resources S
set D; # half products D
set W; # products W
set S_amount;

param S_max_prod {s in S};
param S_limits {s in S, sa in S_amount};
param S_prices {s in S, sa in S_amount};
param D_from_S {s in S, d in D};
param heat_factory_limits {sa in S_amount};
param heat_factory_prices {sa in S_amount};
param factory_capacity;
param heat_factory_capacity;
param worker_price;
param worker_capacity;

param min_demand;
param W_prices {w in W};

#transport
param train_capacity;
param car_capacity;
param truck_capacity;
param train_price;
param car_price;
param truck_price;

param reference_prod_cost;
param reference_deficiency {w in W};
param max_cost;

####
param cost_lambda;
param deficiency_lambda {w in W};
param epsilon;
param beta;

#decision variables
var S_usage {s in S} >= 0;
var S_usage_amount {s in S, sa in S_amount} >= 0;
var u_s1_usage {1..2} binary;
var u_s2_usage {1..2} binary;
var u_s3_usage {1..2} binary;
var u_s2_heat_f_usage {1..2} binary;
var S_usage_cost {s in S} >= 0;
var D_usage_cost {d in D} >= 0;
var heat_factory_cost >= 0;

var D_produced {d in D} >= 0;
var W_produced {w in W} >= 0;

var car_cost >= 0;
var train_cost >= 0;
var truck_cost >= 0;

var total_cost >= 0;
var income >= 0;
var profit;
var total_deficiency {w in W};


### 
var cost_delta;
var deficiency_delta {w in W};
var delta;
var v;
var z_deficiency  {w in W};
var z_cost;

#model
s.t. S2_production2: S_usage['S2'] + S_usage['S3'] <= S_max_prod['S2'];
s.t. S2_production1: S_usage['S1'] <= S_max_prod['S1'];

s.t. S_distribution {s in S}: sum {sa in S_amount} S_usage_amount[s, sa] = S_usage[s];

s.t. S1_limit1: S_usage_amount['S1', 'L1'] <= S_limits['S1', 'L1'];
s.t. S1_limit2: S_usage_amount['S1', 'L2'] <= (S_limits['S1', 'L2'] - S_limits['S1', 'L1']) * u_s1_usage[1];
s.t. S1_limit3: S_usage_amount['S1', 'L1'] >= S_limits['S1', 'L1'] * u_s1_usage[1];
s.t. S1_limit4: S_usage_amount['S1', 'L2'] >= (S_limits['S1', 'L2'] - S_limits['S1', 'L1']) * u_s1_usage[2];
s.t. S1_limit5: S_usage_amount['S1', 'L3'] <= 9999999 * u_s1_usage[2];

s.t. S2_limit1: S_usage_amount['S2', 'L1'] <= S_limits['S2', 'L1'];
s.t. S2_limit2: S_usage_amount['S2', 'L2'] <= (S_limits['S2', 'L2'] - S_limits['S2', 'L1']) * u_s2_usage[1];
s.t. S2_limit3: S_usage_amount['S2', 'L1'] >= S_limits['S2', 'L1'] * u_s2_usage[1];
s.t. S2_limit4: S_usage_amount['S2', 'L2'] >= (S_limits['S2', 'L2'] - S_limits['S2', 'L1']) * u_s2_usage[2];
s.t. S2_limit5: S_usage_amount['S2', 'L3'] <= 9999999 * u_s2_usage[2];

s.t. S3_limit1: S_usage_amount['S3', 'L1'] <= S_limits['S3', 'L1'];
s.t. S3_limit2: S_usage_amount['S3', 'L2'] <= (S_limits['S3', 'L2'] - S_limits['S3', 'L1']) * u_s3_usage[1];
s.t. S3_limit3: S_usage_amount['S3', 'L1'] >= S_limits['S3', 'L1'] * u_s3_usage[1];
s.t. S3_limit4: S_usage_amount['S3', 'L2'] >= (S_limits['S3', 'L2'] - S_limits['S3', 'L1']) * u_s3_usage[2];
s.t. S3_limit5: S_usage_amount['S3', 'L3'] <= 9999999 * u_s3_usage[2];


s.t. heat_factory_limit1: S_usage_amount['S3', 'L1'] <= heat_factory_limits['L1'];
s.t. heat_factory_limit11: sum {sa in S_amount} S_usage_amount['S3', sa] <= heat_factory_limits['L3'];
s.t. heat_factory_limit2: S_usage_amount['S3', 'L2'] <= heat_factory_limits['L2'] * u_s2_heat_f_usage[1];
s.t. heat_factory_limit3: S_usage_amount['S3', 'L1'] >= heat_factory_limits['L1'] * u_s2_heat_f_usage[1];
s.t. heat_factory_limit4: S_usage_amount['S3', 'L2'] >= heat_factory_limits['L2'] * u_s2_heat_f_usage[2];
s.t. heat_factory_limit5: S_usage_amount['S3', 'L3'] <= heat_factory_limits['L3'] * u_s2_heat_f_usage[2];

#s.t. binary_limit: u_s2_heat_f_usage[1] + u_s2_heat_f_usage[2] = 1;


s.t. d1_produced_amount: D_produced['D1'] = S_usage['S1'] * D_from_S['S1', 'D1'] + S_usage['S2'] * D_from_S['S2', 'D1'];
s.t. d2_produced_amount: D_produced['D2'] = S_usage['S1'] * D_from_S['S1', 'D2'] + S_usage['S2'] * D_from_S['S2', 'D2'];
s.t. w1_produced_amount: W_produced['W1'] = D_produced['D1'];
s.t. w2_produced_amount: W_produced['W2'] = D_produced['D2'] + sum {sa in S_amount} S_usage_amount['S3', sa];


s.t. S_price {s in S}: S_usage_cost[s] = sum {sa in S_amount} (S_usage_amount[s, sa] * S_prices[s, sa]);

s.t. D_production_cost {d in D}: D_usage_cost[d] = ceil(D_produced[d] / (2 * worker_capacity)) * 2 * worker_price;

s.t. heat_factory_production_cost: heat_factory_cost = heat_factory_prices['L2'] * u_s2_heat_f_usage[1] 
													 + heat_factory_prices['L3'] * u_s2_heat_f_usage[2];

s.t. demand_limits {w in W}: W_produced[w] >= min_demand;

# transport
s.t. calculate_car_cost: car_cost = ceil(S_usage['S1'] / car_capacity) * car_price;
s.t. calculate_train_cost: train_cost = ceil(S_usage['S1'] / train_capacity) * train_price;
s.t. calculate_truck_cost: truck_cost = (ceil(S_usage['S2'] / car_capacity) + ceil(S_usage['S3'] / car_capacity)) * truck_price;


s.t. calculate_total_production_cost: total_cost = car_cost + train_cost + truck_cost
	+ (sum {s in S} S_usage_cost[s]) + (sum {d in D} D_usage_cost[d]) + heat_factory_cost;

s.t. calculate_income: income = W_produced['W1'] * W_prices['W1'] + W_produced['W2'] * W_prices['W2'];
s.t. calculate_profit: profit = income - total_cost;

s.t. reference_in_cost: total_cost - reference_prod_cost;
s.t. reference_in_deficiency {w in W}: total_deficiency[w] = 
(1 - ((min_demand - W_produced[w])/min_demand)) - (1 - reference_deficiency[w]);


s.t. calculate_delta: delta = v + epsilon * ((sum {w in W} z_deficiency[w]) + z_cost);
s.t. v_limit: v <= z_cost;
s.t. v_limit2 {w in W}: v <= z_deficiency[w];
s.t. v_limit3: z_cost <= beta * cost_lambda * ((max_cost - total_cost) - (max_cost - reference_prod_cost));
s.t. v_limit4 {w in W}: z_deficiency[w] <= beta * deficiency_lambda[w] * deficiency_delta[w];
s.t. v_limit5: z_cost <= cost_lambda * ((max_cost - total_cost) - (max_cost - reference_prod_cost));
s.t. v_limit6 {w in W}: z_deficiency[w] <= deficiency_lambda[w] * deficiency_delta[w];

 maximize target: delta;
# maximize target: profit;
# minimize target: total_cost;
# maximize target: income;