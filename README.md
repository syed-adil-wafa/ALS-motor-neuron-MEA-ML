## Multivariate electrophysiological phenotyping of human iPSC-derived spinal motor neurons in ALS using machine learning

### Summary
Many nervous system diseases, such as Amyotrophic Lateral Sclerosis (ALS), exhibit disruptions in neuronal activity and altered neural network connectivity ([Wainger *et al.*, 2014](https://www.ncbi.nlm.nih.gov/pubmed/24703839); [Winden *et al.*, 2019](https://www.ncbi.nlm.nih.gov/pubmed/31591157)). The electrophysiological properties of neuronal networks are increasingly being characterized by multi-electrode arrays ([Trujillo *et al.*, 2019](https://www.ncbi.nlm.nih.gov/pubmed/31474560)). Using multi-electrode array recordings, we monitored spontaneous extracellular field potentials of human induced pluripotent stem cell (iPSC)-derived spinal motor neurons from patients with ALS and isogenic controls. ALS is a neurodegenerative disease characterized by loss of motor neurons in the brain and spinal cord. We observed that increased spiking, increased bursting, and increased network bursts underlie hyper-excitability in iPSC-derived motor neurons with a *SOD1<sup>A4V/+</sup>* mutation, which corresponds with clinical features of hyper-excitability in ALS patients. To determine whether electrophysiological patterns exist in this disease model, we implemented a machine learning algorithm and quantified the importance of 33 electrophysiological parameters in distinguishing diseased and control neurons. Machine learning results indicated different spiking and bursting parameters to be important predictors of diseased neurons during early and late stages of development, respectively.

### Methods
All experiments were conducted after receiving institutional review board approval. iPSCs were generated from patient fibroblasts and spinal motor neuron differentiations were performed as described in [Kiskinis *et al.* (2014)](https://pubmed.ncbi.nlm.nih.gov/24704492/). Neurons were plated on poly-D-lysine/laminin coated 96-well multi-electrode array plates. Recordings from 8 extracellular electrodes in each well were made using a Maestro (Axion BioSystems) multi-electrode array recording amplifier with a head stage that maintained a temperature of 37 &deg;C. 
#### Spike, burst, and network burst detection
Data were sampled at 12.5 kHz, digitized, and analyzed using Axion Integrated Studio software (Axion BioSystems) with 200 Hz high-pass and 3 kHz low-pass Butterworth filters. Spikes were detected using an adaptive spike detection threshold set at 6 times the standard deviation for each electrode with 0.84 ms and 2.16 ms pre- and post-spike durations and non-overlapping 1 s binning. Bursts were detected using an ISI threshold with minimum 5 spikes and maximum 100 ms ISI. Network bursts were detected with minimum 10 spikes and maximum 100 ms ISI with 25% of electrodes participating. Synchrony metrics between electrodes were computed within 20 ms windows.
#### Data analysis
Downstream data analysis was performed using in-house scripts written in MATLAB 2016a (The MathWorks, Inc.).

![alt text](https://github.com/syed-adil-wafa/MEA-phenotyping-of-ALS-motor-neurons/blob/master/figures/feature_importance.jpg)
![alt text](https://github.com/syed-adil-wafa/MEA-phenotyping-of-ALS-motor-neurons/blob/master/figures/ALS_electrophysiological_features.jpg)

### Acknowledgements
Laboratory of Clifford Woolf: https://kirbyneuro.org/WoolfLab/
<br/> Human Neuron Core: http://www.childrenshospital.org/research/labs/human-neuron-core
<br/> Laboratory of Mustafa Sahin: http://sahin-lab.org/

### References
Kiskinis, E., Sandoe, J., Williams, L.A., Boulting, G.L., Moccia, R., Wainger, B.J., Han, S., Peng, T., Thams, S., Mikkilineni, S., Mellin, C., Merkle, F.T., Davis-Dusenbery, B.N., Ziller, M., Oakley, D., Ichida, J., Costanzo, S.D., Atwater, N., Maeder, M.L., Goodwin, M.J., Nemesh, J., Handsaker, R.E., Paull, D., Noggle, S., McCarroll, S.A., Joung, J.K., Woolf, C.J., Brown, R.H., & Eggan, K. (2014). Pathways disrupted in human ALS motor neurons identified through genetic correction of mutant *SOD1*. *Cell Stem Cell*, *14*(6), 781-795. DOI: [10.1016/j.stem.2014.03.004](https://pubmed.ncbi.nlm.nih.gov/24704492/)
<br/>
<br/> Wainger, B.J., Kiskinis, E., Mellin, C., Wiskow, O., Han, S.S.W., Sandoe, J., Perez, N.P., Williams, L.A., Lee, S., Boulting, G., Berry, J.D., Brown, Jr., R.H., Cudkowicz, M.E., Bean, B.P., Eggan, K., & Woolf, C.J. (2014). Intrinsic Membrane Hyperexcitability of Amyotrophic Lateral Sclerosis Patient-Derived Motor Neurons. *Cell Reports*, *7*(1), 1-11. DOI: [10.1016/j.celrep.2014.03.019](https://www.ncbi.nlm.nih.gov/pubmed/24703839)
<br/>
<br/> Trujillo, C.A., Gao, R., Negraes, P.D., Gu, J., Buchanan, J., Preissl, S., Wang, A., Wu, W., Haddad, G.G., Chaim, I.A., Domissy, A., Vandenberghe, M., Devor, A., Yeo, G.W., Voytek, B., & Muotri, A.R. (2019). Complex Oscillatory Waves Emerging from Cortical Organoids Model Early Human Brain Network Development. *Cell Stem Cell*, *25*(4), 558-569. DOI: [10.1016/j.stem.2019.08.002](https://www.ncbi.nlm.nih.gov/pubmed/31474560)
<br/>
<br/> Winden, K.D., Sundberg, M., Yang, C., Wafa, S.M.A., Dwyer, S., Chen, P.-F., Buttermore, E.D., & Sahin, M. (2019). Biallelic mutations in *TSC2* lead to abnormalities associated with cortical tubers in human iPSC-derived neurons. *The Journal of Neuroscience*, *39*(47), 9294-9305. DOI: [https://doi.org/10.1523/JNEUROSCI.0642-19.2019](https://www.ncbi.nlm.nih.gov/pubmed/31591157)
