function investmentWidget(M,t,r,S,b,Tinc_now,Tcap_now,Tinc_fut,Tcap_fut)
% 
% investmentWidget(M,t,r,S,b,Tinc_now,Tcap_now,Tinc_fut,Tcap_fut)
%
% Evaluates equations in'Reasoning about Retirement Investment Options'
%
% INPUTS
%  M         dollars to be invested at time 0  
%  t         years to leave invested              
%  r         growth rate, where r=1 means no growth
%  S         value of investments already in taxable accounts at t0 
%  b         basis of assets in taxable accounts at t0 
%  Tinc_now  income tax rate at t0              
%  Tcap_now  long-term capital gains tax rate at t0    
%  Tinc_fut  income tax rate at time t           
%  Tcap_fut  long-term capital gains tax rate at time t    
%
% Computes after-tax usable funds at time t, on different assumptions about
% retirement investment strategies implemented at time t0.
% Also provides ratios between options, which don't depend on M, t, or r 
% 
% Outputs are printed to console. No variables are returned. Equation
% numbers stated in the output correspond to the draft of 2025.10.19,
% subject to change in future revisions.
%
% The following code replicates the numbers in Section 8 of the paper:
% M=1; t=35;  r=1.10/1.02; S=20000;  b=0.8;
% Tinc_now=0.333; Tcap_now=0.243; Tinc_fut=0.24; Tcap_fut=0.15;
% investmentWidget(M,t,r,S,b,Tinc_now,Tcap_now,Tinc_fut,Tcap_fut)
% 
% CAVEATS 
% This is not financial advice and does not claim to be a complete analysis
%
% The code makes a simplifying assumption that one marginal tax rate
% governs all the amounts at a given time. It does not deal with the
% possibility that the transactions could alter your tax bracket or part of
% the amount could fall below a tax bracket threshold.
%
% The code does NOT support:
% Short term capital gains - assumes all gains are long term when realized
% 
% FICA (tax on wages for Social Security and Medicare): is not part of
% federal income tax as applicable to retirement account taxation rules
%
% Investment Income Tax (NIIT) or Alternative Minimum Tax (AMT)  - these
% would be too complicated to implement, and if they are applicable, this
% conversation is probably not relevant anyway.
% 2025.10.19
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% These variables just help simplify equations
Kinc.now=1-Tinc_now;
Kinc.fut=1-Tinc_fut;
Kcap.now=1-Tcap_now;
Kcap.fut=1-Tcap_fut;
g=1-b; % embedded gains in taxable account

fprintf('\n\n##################################################\n');
Eqn1=M*r^t; % baseline wealth at the end, with no tax
fprintf('Equation 1 (baseline of no tax) \t\tMfuture = %.2f\n',Eqn1);

% Eqn2= (M*Kinc.now * r^t *Kcap.fut) + M*Kinc.now*Tcap_fut;
% equation 2 rearranges to equation 3
Eqn3=M*Kinc.now * (r^t*Kcap.fut + Tcap_fut); % wealth at end, after tax
fprintf('Equation 3 (naive investing) \t\t\tMfuture = %.2f\n',Eqn3);
 
% Eqn4 rearranges to equation 5
Eqn5= Kinc.now * (Kcap.fut + Tcap_fut/(r^t)); %  ratio of fully taxed/baseline
fprintf('Equation 5 naive/baseline \t\t\t\tratio = %.2f\n',Eqn5);
% Eqn5Asymptote=Kinc.now*Kcap.fut; %asymptotic ratio of fully taxed/baseline

Eqn6 = M*r^t*Kinc.fut;   % wealth at end, tax deferred 
fprintf('Equation 6 (pretax,tax-deferred) \t\tMfuture = %.2f\n',Eqn6);

Eqn7 = Kinc.fut; % ratio of tax deferred to baseline
fprintf('Equation 7 deferred/baseline \t\t\tratio = %.2f\n',Eqn7);

Eqn8 = M*r^t*Kinc.now;  %    wealth at end, taxfree
fprintf('Equation 8 (aftertax,taxfree) \t\t\tMfuture = %.2f\n',Eqn8);

Eqn9 = Kinc.now; % ratio of taxfree to baseline
fprintf('Equation 9 taxfree/baseline  \t\t\tratio = %.2f\n',Eqn9);

Eqn10 = Kinc.fut/Kinc.now;  % ratio of tax deferred to taxfree
fprintf('Equation 10 deferred/taxfree  \t\t\tratio = %.2f\n',Eqn10);

RawDeal=M*Kinc.now * (r^t*Kinc.fut + Tinc_fut); % wealth at end, after tax
fprintf('After-tax contrib to tax-deferred  \t\tMfuture = %.2f\n',RawDeal);

%%%%%%%%%%%%%%%%%%
% Section 7 of paper: existing taxable investments
fprintf('\nRegarding selling taxable investments held at t0:\n'); 
 
Eqn12=S*r^t*Kcap.fut + S*b*Tcap_fut;
%which rearranges to
Eqn13 = S*r^t*(Kcap.fut + b*Tcap_fut/r^t); 
fprintf('Equation 13 (leave in taxable account)\t\t\t\tMfuture = %.0f\n',Eqn13);

Eqn11 = S*r^t*(g*Kcap.now + b);
fprintf('Equation 11 (sell taxable assets,put in tax-free account)\tMfuture = %.0f\n',Eqn11);

% selling taxable assets to invest pretax in tax-deferred
% These calculations not in the paper so there are no Equation numbers
% But these are computed for the example in section 8
NetProceeds=S* (b + g*Kcap.now); % cash after tax from selling
fprintf('Selling the %.0f portfolio with %.2f basis would yield %.0f cash after taxes\n',...
    S,b,NetProceeds);
% pretax contribution that reduces takehome by the amount of the proceeds
X=NetProceeds/Kinc.now; 
fprintf('Contributing %.0f pretax to tax-deferred account would reduce take-home pay by %.0f\n',...
    X, NetProceeds)

% value at time t of tax-deferred investment of this pretax contribution 
EqnX = X*r^t * Kinc.fut;% value after tax paid at time t
fprintf('Selling taxable assets/putting pre-tax in tax-deferred yields\t\tMfuture = %.0f\n',EqnX);

%not displayed, but shown in paper
% Eqn14 = (g*Kcap.now + b) > (Kcap.fut + b*Tcap_fut/r^t);
% advantageRatio = (g*Kcap.now + b) / (Kcap.fut + b*Tcap_fut/r^t);

end