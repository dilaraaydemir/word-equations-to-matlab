![](media/image1.emf){width="4.004192913385827in" height="4.243478783902012in"}

$$\Delta P = P_{T,pre} - P_{T,after}$$

$$\Delta V_{h} = V_{h1} - V_{h2} \rightarrow \ \Delta{\dot{V}}_{h} = {\dot{V}}_{h1} - {\dot{V}}_{h2}$$

$${\dot{V}}_{h1} = Q_{vad} - Q_{gp},\ \ {\dot{V}}_{h2} = Q_{gp} - Q_{vad}$$

$$\Delta{\dot{V}}_{h} = 2\left( Q_{vad} - Q_{gp} \right)$$

$$Q_{gp} = \alpha_{\omega}\omega - \frac{1}{R_{bf}}\Delta P$$

$$\dot{\omega} = - \frac{\tau(\omega)}{J} + \frac{K_{i}}{J}i_{gp} - \frac{\alpha_{P}}{J}\Delta P$$

$$\dot{{\dot{i}}_{gp}} = - \frac{K_{emf}}{L}\omega - \frac{R_{gp}}{L}i_{gp} + \frac{1}{L}V_{in}$$

$$\tau(\omega) = \tau_{1}sgn(\omega) + \tau_{2}\omega$$

$$J_{gp} = 0.293*10^{- 3}\ Kg.m^{2},\ \ L_{gp} = 1.44*10^{- 3}\ H,\ \ K = 72.4*10^{- 3}\ V.s\ $$

$$R_{bf} = 2.399*10^{9}\ \ Pa.s.m^{- 3},\ \ R_{gp} = 0.48\ \ \Omega$$

$$\alpha_{\omega} = 1.59*10^{- 6}\ \ m^{3}.rad^{- 1}\ \ ,\ \ \alpha_{P} = 3.625*10^{- 6}\ m^{3}$$

$$\tau_{1} = 44.9*10^{- 6}\ N,\ \ \tau_{2} = 0.3*10^{- 3}\ N.s.m^{- 1}$$

$$\omega = rad.s^{- 1},\ \ P = Pa,\ \ \dot{V} = Q = m^{3}.s^{- 1}\ ,\ \ i = A,\ \ v = V$$

$$\Delta{\dot{V}}_{h} = 2Q_{vad} + \frac{2}{R_{bf}}\Delta P - 2\alpha_{\omega}\omega$$

$$\dot{\omega} = - \frac{\tau_{1}}{J_{gp}}sgn(\omega) - \frac{\alpha_{P}}{J_{gp}}\Delta P - \frac{\tau_{2}}{J_{gp}}\omega + \frac{K}{J_{gp}}i_{gp}$$

$$\dot{{\dot{i}}_{gp}} = - \frac{K}{L_{gp}}\omega - \frac{R_{gp}}{L_{gp}}i_{gp} + \frac{1}{L_{gp}}v_{in}$$

Adaptive Backstepping

$$f_{1} = 2Q_{vad} - \frac{2}{R_{bf}}\Delta P,\ \ f_{2} = - \tau_{1}sgn(\omega) - \alpha_{P}\Delta P\ $$

$$g_{1} = - 2\alpha_{\omega},\ \ g_{2} = - \tau_{2},\ \ g_{3} = K$$

$$g_{4} = - K,\ \ g_{5} = - R_{gp}\ $$

$$\theta_{1} = \frac{1}{J_{gp}},\ \ \theta_{2} = \frac{1}{L_{gp}}$$

$${\dot{x}}_{1} = f_{1} + g_{1}x_{2}$$

$${\dot{x}}_{2} = \theta_{1}\left( f_{2} + g_{2}x_{2} + g_{3}x_{3} \right)$$

$${\dot{x}}_{3} = \theta_{2}\left( g_{4}x_{2} + g_{5}x_{3} + u \right)$$

$$z_{2} = \phi_{2} - x_{2},\ \ z_{3} = \phi_{3} - x_{3}$$

$$x_{2} = \phi_{2} - z_{2},\ \ x_{3} = \phi_{3} - z_{3}$$

$${\dot{x}}_{1} = f_{1} + g_{1}x_{2}$$

$${\dot{z}}_{2} = {\dot{\phi}}_{2} - \theta_{1}f_{2} - \theta_{1}g_{2}x_{2} - \theta_{1}g_{3}x_{3}$$

$${\dot{z}}_{3} = {\dot{\phi}}_{3} - \theta_{2}g_{4}x_{2} - \theta_{2}g_{5}x_{3} - \theta_{2}u$$

$${\dot{x}}_{1} = f_{1} + g_{1}\left( \phi_{2} - z_{2} \right)$$

$${\dot{z}}_{2} = {\dot{\phi}}_{2} - \theta_{1}f_{2} - \theta_{1}g_{2}\left( \phi_{2} - z_{2} \right) - \theta_{1}g_{3}\left( \phi_{3} - z_{3} \right)$$

$${\dot{z}}_{3} = {\dot{\phi}}_{3} - \theta_{2}g_{4}\left( \phi_{2} - z_{2} \right) - \theta_{2}g_{5}\left( \phi_{3} - z_{3} \right) - \theta_{2}u$$

$${\tilde{\theta}}_{1} = {\hat{\theta}}_{1} - \theta_{1} \rightarrow {\dot{\tilde{\theta}}}_{1} = {\dot{\hat{\theta}}}_{1},\ \ {\tilde{\theta}}_{2} = {\hat{\theta}}_{2} - \theta_{2} \rightarrow {\dot{\tilde{\theta}}}_{2} = {\dot{\hat{\theta}}}_{2}$$

$$V = \frac{1}{2}x_{1}^{2} + \frac{1}{2}z_{2}^{2} + \frac{1}{2}z_{3}^{3} + \frac{1}{2\gamma_{1}}{\tilde{\theta}}_{1}^{2} + \frac{1}{2\gamma_{2}}{\tilde{\theta}}_{2}^{2} \rightarrow \dot{V} = x_{1}{\dot{x}}_{1} + z_{2}{\dot{z}}_{2} + z_{3}{\dot{z}}_{3} + \frac{1}{\gamma_{1}}{\tilde{\theta}}_{1}{\dot{\tilde{\theta}}}_{1} + \frac{1}{\gamma_{2}}{\tilde{\theta}}_{2}{\dot{\tilde{\theta}}}_{2}$$

$$\dot{V} = x_{1}\left\lbrack f_{1} + g_{1}\left( \phi_{2} - z_{2} \right) \right\rbrack + z_{2}\left\lbrack {\dot{\phi}}_{2} - \left( {\hat{\theta}}_{1} - {\tilde{\theta}}_{1} \right)f_{2} - \left( {\hat{\theta}}_{1} - {\tilde{\theta}}_{1} \right)g_{2}\left( \phi_{2} - z_{2} \right) - \left( {\hat{\theta}}_{1} - {\tilde{\theta}}_{1} \right)g_{3}\left( \phi_{3} - z_{3} \right) \right\rbrack + z_{3}\left\lbrack {\dot{\phi}}_{3} - \left( {\hat{\theta}}_{2} - {\tilde{\theta}}_{2} \right)g_{4}\left( \phi_{2} - z_{2} \right) - \left( {\hat{\theta}}_{2} - {\tilde{\theta}}_{2} \right)g_{5}\left( \phi_{3} - z_{3} \right) - \left( {\hat{\theta}}_{2} - {\tilde{\theta}}_{2} \right)u\text{~} \right\rbrack + \frac{1}{\gamma_{1}}{\tilde{\theta}}_{1}{\dot{\hat{\theta}}}_{1} + \frac{1}{\gamma_{2}}{\tilde{\theta}}_{2}{\dot{\hat{\theta}}}_{2}$$

Rearrange

$$\dot{V} = x_{1}\left\lbrack f_{1} + g_{1}\phi_{2} \right\rbrack + z_{2}\left\lbrack {\dot{\phi}}_{2} - g_{1}x_{1} - {\hat{\theta}}_{1}f_{2} - {\hat{\theta}}_{1}g_{2}\phi_{2} + {\hat{\theta}}_{1}g_{2}z_{2} - {\hat{\theta}}_{1}g_{3}\phi_{3} \right\rbrack + z_{3}\left\lbrack {\dot{\phi}}_{3} - {\hat{\theta}}_{1}g_{3}z_{2} - {\hat{\theta}}_{2}g_{4}\phi_{2} + {\hat{\theta}}_{2}g_{4}z_{2} - {\hat{\theta}}_{2}g_{5}\phi_{3} + {\hat{\theta}}_{2}g_{5}z_{3} - {\hat{\theta}}_{2}u \right\rbrack + {\tilde{\theta}}_{1}\left( \frac{1}{\gamma_{1}}{\dot{\hat{\theta}}}_{1} + {f_{2}z}_{2} + g_{2}\phi_{2}z_{2} - g_{2}z_{2}^{2} + g_{3}\phi_{3}z_{2} + g_{3}z_{2}z_{3} \right) + {\tilde{\theta}}_{2}\left( \frac{1}{\gamma_{2}}{\dot{\hat{\theta}}}_{2} + g_{4}\phi_{2}z_{3} - g_{4}z_{2}z_{3} + g_{5}\phi_{3}z_{3} - g_{5}z_{3}^{2} + z_{3}u \right)$$

Solve for $\phi_{2},\ \phi_{3},\ {\dot{\hat{\theta}}}_{1}$ and ${\dot{\hat{\theta}}}_{2}$ Such that

$$\dot{V} = - k_{1}x^{2} - k_{2}z_{2}^{2} - k_{3}z_{3}^{2}$$

1^st^ step

$$x_{1}\left\lbrack f_{1} + g_{1}\phi_{2} \right\rbrack = - k_{1}x_{1}^{2}$$

$$\phi_{2} = \frac{1}{g_{1}}\left( - k_{1}x_{1} - f_{1} \right)$$

2^nd^ step

$$z_{2}\left\lbrack {\dot{\phi}}_{2} - {\hat{\theta}}_{1}f_{2} - {\hat{\theta}}_{1}g_{2}\phi_{2} + {\hat{\theta}}_{1}g_{2}z_{2} - {\hat{\theta}}_{1}g_{3}\phi_{3} - g_{1}x_{1} \right\rbrack = - k_{2}z_{2}^{2}$$

$$\phi_{3} = \frac{1}{g_{3}}\left( \frac{1}{{\hat{\theta}}_{1}}{\dot{\phi}}_{2} - f_{2} - g_{2}\phi_{2} + g_{2}z_{2} - \frac{1}{{\hat{\theta}}_{1}}g_{1}x_{1} + \frac{1}{{\hat{\theta}}_{1}}k_{2}z_{2} \right)$$

3^rd^ step

$$z_{3}\left\lbrack {\dot{\phi}}_{3} - {\hat{\theta}}_{1}g_{3}z_{2} - {\hat{\theta}}_{2}g_{4}\phi_{2} + {\hat{\theta}}_{2}g_{4}z_{2} - {\hat{\theta}}_{2}g_{5}\phi_{3} + {\hat{\theta}}_{2}g_{5}z_{3} - {\hat{\theta}}_{2}u \right\rbrack = - k_{3}z_{3}^{2}$$

$$u = \frac{1}{{\hat{\theta}}_{2}}{\dot{\phi}}_{3} - g_{4}\phi_{2} + g_{4}z_{2} - g_{5}\phi_{3} + g_{5}z_{3} + \frac{{\hat{\theta}}_{1}}{{\hat{\theta}}_{2}}g_{3}z_{2} + \frac{1}{{\hat{\theta}}_{2}}k_{3}z_{3}$$

1^st^ Adaptation law

$${\tilde{\theta}}_{1}\left( \frac{1}{\gamma_{1}}{\dot{\hat{\theta}}}_{1} + {f_{2}z}_{2} + g_{2}\phi_{2}z_{2} - g_{2}z_{2}^{2} + g_{3}\phi_{3}z_{2} + g_{3}z_{2}z_{3} \right) = 0$$

$${\dot{\hat{\theta}}}_{1} = \gamma_{1}\left( - {f_{2}z}_{2} - g_{2}\phi_{2}z_{2} + g_{2}z_{2}^{2} - g_{3}\phi_{3}z_{2} - g_{3}z_{2}z_{3} \right)$$

2^nd^ Adaptation law

$${\tilde{\theta}}_{2}\left( \frac{1}{\gamma_{2}}{\dot{\hat{\theta}}}_{2} + g_{4}\phi_{2}z_{3} - g_{4}z_{2}z_{3} + g_{5}\phi_{3}z_{3} - g_{5}z_{3}^{2} + z_{3}u \right) = 0$$

*\*
$${\dot{\hat{\theta}}}_{2} = \gamma_{2}\left( - g_{4}\phi_{2}z_{3} + g_{4}z_{2}z_{3} - g_{5}\phi_{3}z_{3} + g_{5}z_{3}^{2} - z_{3}u \right)$$
