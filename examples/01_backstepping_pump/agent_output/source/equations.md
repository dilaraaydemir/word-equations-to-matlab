![](source/media/image1.emf){width="4.004192913385827in" height="4.243478783902012in"}

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

Define

$$x_{1} = \Delta V,\ \ x_{2} = \omega,\ \ x_{3} = i_{gp}$$

$$f_{1} = 2Q_{vad} + \frac{2}{R_{bf}}\Delta P,\ \ f_{2} = - \frac{\tau_{1}sgn(\omega)}{J_{gp}} - \frac{\alpha_{P}}{J_{gp}}\Delta P\ $$

$$g_{1} = - 2\alpha_{\omega},\ \ g_{2} = - \frac{\tau_{2}}{J_{gp}},\ \ g_{3} = \frac{K}{J_{gp}}$$

$$g_{4} = - \frac{K}{L_{gp}},\ \ g_{5} = - \frac{R_{gp}}{L_{gp}},\ \ g_{6} = \frac{1}{L_{gp}}$$

$${\dot{x}}_{1} = f_{1} + g_{1}x_{2}$$

$${\dot{x}}_{2} = f_{2} + g_{2}x_{2} + g_{3}x_{3}$$

$${\dot{x}}_{3} = g_{4}x_{2} + g_{5}x_{3} + g_{6}u$$
