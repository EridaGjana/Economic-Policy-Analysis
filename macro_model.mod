// Question 7 Run a stochastic simulation of the model
// First I define the variables based on the equations of the model
var y c n i pi w  r_nat ytilde g t r nu ;
// y is actual output
// c is actual consumption
// n is labor
// i is nominal interest rate
// pi is inflation
// w is real wage
// r_nat is natural rate of interest
// ytilde is output gap
// g is government spending
// t is taxes
// r is real interest rate
// nu is monetary policy shock variable


varexo eps_g eps_nu; // Shock to government spending g

//I set the values for the all parameters used in the model
parameters alpha, rho, theta, varphi, eta_i,eta_g, epsilon, mu, piast, beta, kappa, phi, tau, gamma , y_nat, gbar;
alpha = 0;                  // production function // specified in the model
rho = 0.01;                 // time preference rate // Lecture 8 , nkmodel.mod
varphi = 1;                 // inverse Frisch elasticity //Lecture 8 , nkmodel.mod
theta = 1;                  // inverse elasticity of intertemporal substitution //Lecture 8 , nkmodel.mod
gamma = 0.667;              // Calvo parameter // Lecture 8 , nkmodel.mod and also Chapter 8 slides , page 25
eta_i = 0.5;                // monetary policy shock persistence// Lecture 8 , nkmodel.mod
eta_g = 0.9;                // persistence of government spending shock // Lecture 8 , nkmodel.mod
epsilon = 6;                // elasticity of substitution // Lecture 8 , nkmodel.mod
piast = 0;                  // inflation target // Lecture 8 , nkmodel.mod
phi = 1.5;                  // interest rate rule parameter // Lecture 8 , nkmodel.mod
mu = epsilon/(epsilon-1);   // mark-up // Specified in the model
y_nat= -mu/ theta + varphi; // natural output value // Specified in the model equation (9)
beta = 1/(1+rho+piast); // Discount factor // Specified in the model
kappa = (1-gamma)*(1-gamma*beta)*(theta+varphi)/gamma*(1+epsilon); // coef for effect of output gap in the inflation rate //Specified in the model
tau = 0.2103; // propotion of government spending to GDP // Clculated in octave script
gbar= -ln(1-0.2103); // The steady state value of g // Specified from the model equation (8)

// Specify the model equations
model;
y = c + g;
n=y;
//  New Keynesian IS Curve
ytilde = ytilde(+1)-(1/theta)*(i-pi(+1)-r_nat);
// Natural Rate of Interest
r_nat= rho + theta*(y_nat(+1)-y_nat - g(+1) + g );
// Wage
w= theta*c+ varphi*n;
//New Keynesian Phillips Curve
pi = pi (+1) + kappa*ytilde;
// taxes
t = g;
// Output gap
ytilde = y-y_nat;
// Fisher Equation
r= i-pi(+1);
// Monetary policy rule
i = rho+piast+phi*(pi-piast)+nu;
nu = eta_i*nu(-1)+eps_nu;
//level of government spending
g= (1-eta_g)*gbar+eta_g*g(-1)+eps_g;
end;

// Set the initial values for the model's variables, providing a starting point for the simulation.
initval;
g=-ln(1-0.2103); // I use the value of g bar from the steady state
t=-ln(1-0.2103); //  Since t is equal to g in the steady state
nu = 0; // Lecture 8 , nkmodel.mod
pi = 0; //Lecture 8 , nkmodel.mod
y = 0.5+(-ln(1-0.2103)); // Since y=c+g
r = 0.05; //Lecture 8 , nkmodel.mod
i = 0.03;  //Lecture 8 , nkmodel.mod
r_nat = 0.03; //Lecture 8 , nkmodel.mod
c = 0.5;   // Lecture 8 moncomp_stoch.mod
w = 1.5;   // Lecture 8 moncomp_stoch.mod
n = 0.3;   // Lecture 8 moncomp_stoch.mod
ytilde =0; // In the initial stage actual y and natural y are the same .
end;
steady;// Calcuates the steady state of the model

// check

// Specify temporary shock
shocks;
var eps_g; stderr 0.1; // Specify the sandard deviation of the shock.
var  eps_nu; stderr 0.003; // Shock of monetary policy
end;

stoch_simul(periods=200, drop=100, order=1, solve_algo=0, irf=40);








