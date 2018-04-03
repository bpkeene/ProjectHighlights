#Project Description:

We wish to derive a fair price schedule for an insurance company offering 10-year term life insurance with a payout of $500,000.  

The problem is fairly open-ended, in that we have freedom in defining our model, with the aim of it being a reasonable description of reality.

I collaborated with my teammates to define the scenario, although the development of the MATLAB model was a solo endeavor.




We make the following assumptions:

-  All simulated people are male
-  The population distribution remains stationary

Simulation protocol:

Draw 1,000,000 people from the population distribution and initialize accordingly;  each person also has an independent probability of 
being sick, and correspondingly their probability of death during a given year is adjusted (accounting for age and health status).

We wish to establish the break-even price schedule (what a person should have to pay for a life insurance policy as a function of their age), accounting for risk-free returns on current capital (nominally via bonds).

We accomplish this via Monte Carlo simulation, and solving a system of differential equations using the aggregated data.


