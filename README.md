# COMP3000

COMP3000 Final Year Project.

Impact of Network Degradation on Keystroke Biometric Authentication

Supervisor: Bogdan Ghita



Trello: https://trello.com/b/Iqpg3ydL/sprint-board



Project Overview

The study investigates the viability of keystroke biometric authentication under network congestion. Keystroke biometric authentication relies on consistent typing patterns. The effectiveness of the authentication system degrades in remote desktop sessions, where network conditions create variability in user typing patterns. 

The aim of this project is to identify the threshold where network conditions begin to make the system unreliable for user authentication. Instead of emulating network traffic, this study applies controlled timing distortions to the CMU keystroke dataset using MATLAB. This simulated traffic is taken from a dataset of network timings of latency, packet loss, and jitter. This approach enables controlled evaluation of how increasing levels of degradation affect performance.

Results have been analysed using biometric evaluation methods including Euclidean Distance, False Acceptance Rate (FAR), False Rejection Rate (FRR), Equal Error Rate (EER), and balanced accuracy. Metrics that are commonly used in biometrics to identify when the system can no longer tell the difference between genuine users and imposters reliably. A crucial threshold was identified after seven levels of network degradation, this relates to approximately 23.54ms latency, 2.22ms jitter, and 12.01% packet loss where the EER exceeded 0.3 and authentication performance significantly declined. These findings contribute to existing research into the behaviour of keystroke authentication in unstable networks, giving a clearer definition of the threshold for failure over remote desktop connection sessions.



Project Aims

1. Develop a controlled distortion model that applies increasing levels of network degradation to keystroke data.

2\. Evaluate the effect of latency, jitter, and packet loss on keystroke biometrics.

3\. Identify the point at which authentication becomes unreliable due to network conditions.



Key Findings

The experiment identified a critical degradation threshold at level 7, where:

\- EER exceeded 0.3

\- Balanced accuracy fell below 70%

\- Genuine–imposter separation dropped below 2.0

\- Average genuine Euclidean distance increased by 1.573 compared with the baseline



Using the mapping method described in the report, this corresponds approximately to:

\- \*\*23.54 ms latency\*\*

\- \*\*2.22 ms jitter\*\*

\- \*\*12.01% packet loss\*\*

These values should be interpreted as approximations, not universal real-world thresholds.

References:
Ali, M.L., Monaco, J.V., Tappert, C.C. and Qiu, M. (2016). Keystroke Biometric Systems for User Authentication. Journal of Signal Processing Systems, 86(2-3), pp.175-190. doi:https://doi.org/10.1007/s11265-016-1114-9.

GDPR (2018). General Data Protection Regulation (GDPR). \[online] GDPR. Available at: https://gdpr-info.eu/.

Ievgeniia Kuzminykh, Bogdan Ghita and Alexandr Silonosov (2020). Impact of Network and Host Characteristics on the Keystroke Pattern in Remote Desktop Sessions. doi:https://doi.org/10.48550/arxiv.2012.03577.

Killourhy, K. and Maxion, R. (2009). Comparing Anomaly-Detection Algorithms for Keystroke Dynamics. \[online] Available at: https://www.cs.cmu.edu/\~maxion/pubs/KillourhyMaxion09.pdf \[Accessed 27 Apr. 2026].

Kuzminykh, I., Ghita, B. and Silonosov, A. (2021). On Keystroke Pattern Variability in Virtual Desktop Infrastructure. Computer Modeling and Intelligent Systems, 2864, pp.238-248. doi:https://doi.org/10.32782/cmis/2864-21.

Monrose, F. and Rubin, A.D. (2000). Keystroke dynamics as a biometric for authentication. Future Generation Computer Systems, 16(4), pp.351-359. doi:https://doi.org/10.1016/s0167-739x(99)00059-x.

Pisani, P.H. (2024). A study on user-specific threshold configuration for keystroke dynamics in the context of adaptive biometric systems. Anais do XXIV Simpósio Brasileiro de Segurança da Informação e de Sistemas Computacionais (SBSeg 2024), \[online] pp.725-731. doi:https://doi.org/10.5753/sbseg.2024.241289.

Rio, A. del (2024). network-anomaly-dataset. \[online] Doi.org. Available at: https://doi.org/10.34740/kaggle/dsv/9325531 \[Accessed 2 May 2026].

Romain Giot, Rosenberger, C. and Dorizzi, B. (2012). Hybrid template update system for unimodal biometric systems. HAL (Le Centre pour la Communication Scientifique Directe). doi:https://doi.org/10.1109/btas.2012.6374539.

Sulong, A., Wahyudi and Siddiqi, M.U. (2009). Intelligent keystroke pressure-based typing biometrics authentication system using radial basis function network. \[online] IEEE Xplore. doi:https://doi.org/10.1109/CSPA.2009.5069206.



