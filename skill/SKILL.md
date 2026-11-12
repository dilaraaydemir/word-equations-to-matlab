---
name: word-equations-to-matlab
description: Take a Word (.docx) control-design document in which the author has solved the easy parts by hand and then listed the remaining steps in words (e.g. "Choose V", "Solve for x2_ref and u", "Take derivative", "Subs f and g"). Check the solved part for errors, then carry out the listed steps symbolically in MATLAB, in the author's MATLAB code style, verify every step with closed-loop Lyapunov checks, handle 0/0 during simplification, and deliver the final control law (e.g. Vin) for Simulink. Use for backstepping-type derivations, including adaptive backstepping, from the control systems workstation.
---

# Word control derivation → MATLAB

The author writes a control derivation in Word. The easy parts are solved by hand; the rest is
a list of steps in plain text, for example:

> Choose V1 = ½ε1², V2 = ½ε2², V3 = ½ε3². Solve for V̇. Subs and rearrange so that there are
> only ε1 and x1,ref terms in TERM1 and no ε3 terms in TERM2. Choose εi·TERMi = −ki·εi².
> Solve for x2,ref, x3,ref and u. Take derivative of x2,ref and x3,ref. Subs ε2 and ε3 to find
> everything in terms of x1, x2, x3 only. Subs f functions and g values to obtain the final u.

Your job:
1. **Check** the hand-solved part (signs, consistency, typos).
2. **Carry out** the listed steps symbolically in MATLAB, in the author's code style.
3. **Verify** every step with a closed-loop Lyapunov check.
4. **Deliver** the final control law in its most explicit physical form, ready for Simulink.

Run MATLAB through the MATLAB MCP tools (`detect_matlab_toolboxes`, `check_matlab_code`,
`run_matlab_file`, `evaluate_matlab_code`). Use the `matlab-use-symbolic-math` skill for
Symbolic Math Toolbox conventions. This skill asks the user questions; run it in the main
session, not inside a subagent that cannot ask.

## Language

Answer in the language the user writes in: questions (S1, S2, ...), progress messages,
REPORT.md and README.md. Keep code, code comments, variable names and file names in English.
The language of the Word document does not decide this; the user's messages do.

## Hard rules

1. **Never modify the user's files** (Word document, reference code). Work on copies.
2. **Every result is saved to a file** in the output folder. Never overwrite earlier runs.
3. **Never silently fix the document.** Report errors and add `_corr` versions; the user decides
   which version the derivation uses.
4. **Do not invent missing information.** Ask (see "Asking questions").
5. **No numbers before simplification.** Physical parameter values are not substituted unless
   the user asks.
6. **A reference solution (e.g. the author's own MATLAB code) is opened only after your own
   derivation is finished and verified**, so that the comparison is independent.

## Asking questions

Collect all questions of a step into one plain-text message (not a question tool with a
limit). Number them (S1, S2, ...): question, why it matters, your recommendation. Wait for the
answers and record them in `inventory.md`.

## Output folder

Create `<document-name>_<YYYY-MM-DD_HHMMSS>/` in the working folder (append `_2`, `_3` if it
exists). ASCII names only. MATLAB file names must start with a letter.

```
README.md                what every file is, which one to open first (written last)
REPORT.md                final report
deriv_<section>.m        the derivation, in the author's code style
<law>_fun.m              Simulink-ready function of the final law (e.g. Vin_fun.m)
results.mat              W_ref_simp, i_ref_simp, Vin_simp (and other final laws)
checks/
├── source/              copy of the Word file, equations.md (pandoc output)
├── inventory.md         sections, solved part, step list, symbol table, questions and decisions
├── side_by_side.md      solved part: document LaTeX next to MATLAB latex() output
├── chk_document.m       checks of the hand-solved part
├── verify_<section>.m   closed-loop checks for every step
├── analysis_<section>.m simplification, singularities, limits
├── compare_reference.m  comparison with a reference solution (if any)
└── analysis_results.md  raw results printed by the check scripts
```
The top level holds only what the author uses: README, REPORT, the derivation, the Simulink
function and the results. Everything that proves the result is in `checks/`; nothing is deleted.

`README.md` is a short table: file | what it is | when to open it. It starts with
"Open first: REPORT.md. The formula for Simulink: <law>_fun.m. The derivation: deriv_<section>.m."

## Running MATLAB code

- Write code to a `.m` file, then run it with `run_matlab_file`. Do not pass long code through
  the shell or long `evaluate_matlab_code` strings.
- Scripts start with `cd(fileparts(mfilename('fullpath')));`.
- Run `check_matlab_code` on every file before running it.
- Functions of time: `syms x1(t)` on its own line, then `assume(x1(t),'real')`
  (`syms x1(t) real` does not apply the assumption and gives warnings).

## Phase A: read and check the document

### A1. Tools and extraction
- `pandoc --version` and `detect_matlab_toolboxes` (Symbolic Math Toolbox required). Stop if missing.
- Copy the Word file to `source/` and run
  `pandoc "source/<name>.docx" -t markdown --wrap=none -o "source/equations.md"`.
- Ignore pandoc artefacts (`*\`, `\$`, `\text{~}`).

### A2. Inventory (`inventory.md`)
- **Sections**: plain-text lines between equations are candidate headings. List them.
- **Solved part**: the equations the author derived (model, definitions of `f_i`, `g_i`,
  error definitions, physical meaning of states). Number them `E<n>` (several in one block:
  `E<n>a`, `E<n>b`; repeats keep the first number).
- **Step list**: the plain-text instructions that are not yet solved. Number them `T1, T2, ...`
  and restate each one as a concrete MATLAB operation, for example:
  - "Choose εi·TERMi = −ki·εi²" → three equations to be solved with `isolate`
  - "Take derivative of x2,ref" → `diff(x2ref, t)` with the system dynamics substituted
- **Notation**: map the document's notation to MATLAB names (e.g. `ε` = error = `z`,
  `x_ref` = `φ` = `phi`). Use the author's code names where they exist (see Phase B).
- **Symbol table**: LaTeX → MATLAB → meaning → kind → time-dependent → assumption.

### A3. Questions (stop point)
Ask in one message, with recommendations:
- scope (which section),
- your restatement of every step `T1, T2, ...`: is this what the author means?,
- ambiguous notation; symbols that look like the same quantity under different names,
- which signals vary in time (their derivatives enter the law) and up to which order,
- which constants are positive,
- implicit links (e.g. is the control input `u` the voltage `v_in`?),
- non-smooth functions such as `sgn(ω)`: first ask for the sign of the argument in operation
  (e.g. "the pump turns one way, so ω > 0 and sgn(ω) = +1"). With a known sign the function is a
  constant and no `dirac` term appears. Drop a `dirac` term only if the user says the sign can change,
  and then state that the law holds only for ω ≠ 0,
- **design choices, each as its own question with the options listed** (never hide them inside the
  step restatement): the Lyapunov function (standard ½Σεi², weighted, integral action, barrier, ...),
  the error sign convention (ε = x_ref − x or x − x_ref), where cross terms go (which TERM), and the
  target V̇. For every option say whether it is a valid Lyapunov function and why. Never offer a term
  that is not positive definite (e.g. ½ε3³) as an option,
- the control goal when the document does not state it: regulation (x1 → 0) or tracking of a
  reference (then the reference's derivatives up to the relative degree enter the law),
- whether each `f_i` depends only on time or also on the states (this changes the derivatives),
- in adaptive designs: which parameters are unknown, and whether a law that divides by an estimate
  θ̂ needs a projection that keeps θ̂ away from 0,
- output format of the final law (default: simplified expression and a Simulink function file).

### A4. Check the hand-solved part
- Translate the solved equations into `chk_document.m` and write `side_by_side.md`. Label `_corr`
  lines "Proposed correction", never "Document".
- **Stop here only if a finding changes the derivation**: a wrong sign or power that the derivation
  would use, a V that is not positive definite, a system that is not in strict-feedback form, or an
  inconsistency the user has not decided yet. Then ask which version to use.
  If all checks pass, or the only findings are notation, units or labels that the derivation does
  not use, do not stop: list the findings in one short message, say which equations the
  derivation uses, and continue with Phase B.
- Check consistency inside the document: does substituting one equation into another give the
  stated result (e.g. a flow equation into the volume equation gives the stated sign of each
  term)? Do the `f_i`, `g_i` definitions match the model? Do stated powers and signs fit their
  pattern (e.g. `½ε3³` among `½ε1²`, `½ε2²`)?
- Is the given V positive definite? A V with a negative or odd-power term (e.g. `−½z2²`, `½z3³`)
  still lets the steps run and the closed-loop check return 0, but proves nothing and can give an
  unstable law. Report it before deriving.
- Is the system in strict-feedback form (each equation adds only the next state, linearly, and u
  appears only in the last one)? If u appears earlier, or the next state enters non-linearly (e.g.
  `x3^2`), say so before deriving and propose how the method must change.
- Report every problem. Ask which version the derivation should use only for problems that change
  the derivation (see the stop rule above).

## Phase B: carry out the steps

### B1. Code style
`deriv_<section>.m` contains **only the derivation and the export**: no prints, no report
text, no extra outputs nobody asked for (no simplified intermediate forms, no derivatives of
the references). Checks go in `checks/`. Follow the author's section layout and names. The
template below was verified against the author's own code (identical Vin, 45 of 45 terms):

```matlab
cd(fileparts(mfilename('fullpath')));

%% Assignment
syms t real
syms x1(t) x2(t) x3(t) f1(t) f1dot(t) f2(t) f2dot(t)
syms f1ddot g1 g2 g3 g4 g5 g6 real
syms k1 k2 k3 positive
syms z2 z3 phi2 phi3 phi2_dot phi3_dot u real            % placeholder symbols, resolved before every diff
placeholders = [phi2 phi2_dot phi3 phi3_dot z2 z3 u];

%% Define system (E..)
x1_dot = f1(t) + g1*x2(t);
x2_dot = ...;
x3_dot = ...;

%% Define new system dynamics (T..)
x2_new = phi2 - z2;                                      % separate name, so x2(t) keeps its time dependence
x3_new = phi3 - z3;
z2_dot = phi2_dot - x2_dot;
z3_dot = phi3_dot - x3_dot;

%% Subs (T..)
x1_dot_s = subs(x1_dot, [x2(t) x3(t)], [x2_new x3_new]);
z2_dot_s = ...;
z3_dot_s = ...;

%% Lyapunov function and its derivative (T..)
V    = x1(t)^2/2 + z2^2/2 + z3^2/2;
Vdot = x1(t)*x1_dot_s + z2*z2_dot_s + z3*z3_dot_s;

%% Define and rearrange terms (T..)
term1     = subs(x1_dot_s, [z2 z3], [0 0]);
x1_z2_coe = diff(x1_dot_s, z2)*x1(t);                    % coefficient by diff: no division by z2, no 0/0
x1_z3_coe = diff(x1_dot_s, z3)*x1(t);
term2     = subs(z2_dot_s, z3, 0) + x1_z2_coe;
z2_z3_coe = diff(z2_dot_s, z3)*z2;
term3     = z3_dot_s + x1_z3_coe + z2_z3_coe;
assert(isequal(simplify(Vdot - (x1(t)*term1 + z2*term2 + z3*term3)), sym(0)), 'Vdot rearrangement is wrong');

%% Solve for xr and u (T..)
phi2_e = rhs(isolate(term1 == -k1*x1(t), phi2));
phi3_e = ...;
u_e    = ...;

%% Solve for xr dot (T..)
d_syms = [diff(x1(t),t) diff(x2(t),t) diff(f1(t),t) diff(f1dot(t),t) diff(f2(t),t)];
d_vals = [x1_dot x2_dot f1dot(t) f1ddot f2dot(t)];
phi2_dot_e = subs(diff(phi2_e, t), d_syms, d_vals);

phi3_r = phi3_e;
for ii = 1:5                                             % repeated subs: one pass may leave placeholders
    phi3_r = subs(phi3_r, [phi2 phi2_dot z2], [phi2_e phi2_dot_e phi2 - x2(t)]);
end
assert(~any(ismember(symvar(phi3_r), placeholders)), 'placeholder left before diff of phi3');
phi3_dot_e = subs(diff(phi3_r, t), d_syms, d_vals);

%% Subs (T..): u in x1, x2, x3 only
u_r = u_e;
for ii = 1:5
    u_r = subs(u_r, [phi2 phi2_dot phi3 phi3_dot z2 z3], [phi2_e phi2_dot_e phi3_r phi3_dot_e phi2 - x2(t) phi3 - x3(t)]);
end
assert(~any(ismember(symvar(u_r), placeholders)), 'placeholder left in u');

%% symfun to sym
%% Physical values (T..)
%% Save and export
```
The last three sections are only named here: "symfun to sym" replaces the time functions by
plain symbols (`[X1 X2 X3 F1 F1dot F2 F2dot]`) in one `subs`; "Physical values" substitutes
`abs_syms -> phys_vals` in one `subs`, simplifies and asserts the allowed symbols (B2);
"Save and export" writes `results.mat` and `<law>_fun.m` (B5). If the document has no physical
values (the model is already written in its final variables), leave that section out and say
so in the report.

The structure above follows the author's three-state backstepping code. For a document with a
different structure (another number of states, no `f_i`/`g_i`, other signals), adapt the
sections to the document instead of forcing the document into this structure; keep the
section names where a section has the same role.

Rules behind the template:
- **The author's style is the default.** The code is written for the author to read. Deviate
  from his constructs only where the deviation prevents a known error. The accepted deviations
  are: explicit `subs` lists, separate names such as `x2_new`, coefficients by `diff`, the
  `assert`s. Use `for ii = 1:5` loops as the author does (not `while` loops); the `assert`
  after each loop catches the case where 5 passes are not enough.
- **Comments explain the code to its reader.** Each `%%` header carries the numbers it
  implements in parentheses, e.g. `%% Subs (T3)` or `%% Define system (E21a-c)`. Where a line
  differs from the author's usual construct, or is not obvious, add a short end-of-line comment
  saying what the line does or why it is written this way, in neutral technical wording (as in
  the example above). Comments never name people ("Ahmed: ..."), never describe what someone
  else would write, and never repeat instructions from this skill (no "one line, no 'real'").
  Do not comment lines whose meaning is clear from the code.
- One statement per line.
- Write `f1(t)`, not `f1`: it is explicit which symbols depend on time.
- Never overwrite a variable with a new meaning (`x2 = phi2 - z2`), and never call `subs(x)`
  without lists: what gets substituted must be visible in the line itself.
- Use these `assert`s: rearrangement correct, no placeholder before `diff` of
  each virtual control that can contain placeholders, no placeholder in `u`, only allowed symbols in the final law. They cost
  nothing and stop the script instead of producing a silently wrong law.
- Names used by the author: states `x1 x2 x3` → `DV W i`; signals `f1 f2`, `f1dot f2dot`,
  `f1ddot`; constants `g1..g6`; gains `k1 k2 k3`; errors `z2 z3`; virtual controls `phi2 phi3`;
  physical `Qvad DP Qvad_dot DP_dot Qvad_ddot DP_ddot a_P a_w Rbf Rgp L J K t1 t2`.

### B2. Rules that prevent known errors
These come from errors found in real lab code. Follow them strictly.

1. **Resolve placeholders before every `diff`.** Placeholder symbols (`phi2`, `phi2_dot`, ...)
   are plain symbols, so `diff(..., t)` treats them as constants and silently drops terms.
   Before each `diff`, substitute with a `for ii = 1:5` loop and explicit lists, then assert
   (see the template):
   ```matlab
   for ii = 1:5
       e = subs(e, [phi2 phi2_dot z2], [phi2_e phi2_dot_e phi2 - x2(t)]);
   end
   assert(~any(ismember(symvar(e), placeholders)), 'placeholder left before diff');
   ```
   `subs` does one pass only: a value that itself contains a placeholder (e.g. `x1_dot`
   containing `phi2`) needs another pass.
2. **Signals keep their time dependence up to the needed order.** Declare `f1(t)`, `f1dot(t)`, ...
   as functions of time and map `diff(f1dot(t),t)` to `f1ddot`. In "symfun to sym", convert
   every one of them (`f1dot(t)=F1dot;` too). At the end assert that the final law contains only
   the allowed physical symbols:
   ```matlab
   allowed = [DV W i Qvad DP Qvad_dot DP_dot Qvad_ddot DP_ddot a_P a_w Rbf Rgp L J K t1 t2 k1 k2 k3];
   assert(all(ismember(symvar(Vin_simp), allowed)), 'unresolved symbol in Vin');
   ```
3. **No division by an error variable when extracting coefficients.** Patterns such as
   `coe = (...)*x1/z2` followed by substituting `z2 = 0` create 0/0. Take the coefficient with
   `diff(expr, z2)` (exact for terms linear in `z2`, which is the backstepping structure) and
   confirm the rearrangement with the `assert` of the template.
   `diff` gives the coefficient only for a linear term. If the expression is polynomial in the
   error (e.g. a `x3^2` term gives `z3^2`), use exact polynomial division or `coeffs` instead.
3a. **A virtual control from a non-linear equation is not solved with `isolate`.** If TERM_i is
   quadratic in the next virtual control, build the coefficients a, b, c explicitly, assert the
   leading coefficient, write both roots with a root selector `s = ±1`, report the discriminant
   condition D > 0 and the singularity at D = 0, and let the user choose the root (use the
   physical meaning, e.g. ω > 0, when the document gives it).
4. **Keep `f_i` and `g_i` symbolic during the derivation.** Substitute physical values only in the
   last section. This keeps expressions short and keeps `sign(ω)` out of the differentiation.
   Substitute `sign(ω)` with the sign the user gave (e.g. +1 for ω > 0). Only if the user says the
   sign can change: drop the `dirac` term and state that the law holds for ω ≠ 0.
5. **Adaptive designs.** Write each unknown parameter as estimate plus error (θ = θ̂ + θ̃, or the
   document's convention), add `θ̃²/(2γ)` per parameter to V, and collect all θ̃ terms into
   TERM_θ. Derivatives of virtual controls must use the estimated dynamics (θ̂ in place of θ).
   If an unknown parameter appears in any equation before the last one, it also enters the
   derivatives of later virtual controls: the plain "TERM_θ = 0" laws then leave a residual in V̇.
   Say so before deriving and use tuning functions (add the z_j·∂φ_j/∂x·(regressor) terms to the
   adaptation law, and use the full adaptation law, not only its z = 0 part, in later steps).
   Assert that the true parameters (and θ̃) do not appear in u or in any adaptation law. State in
   the report that V̇ ≤ 0 does not imply θ̂ → θ without persistent excitation.

### B3. Verify every step (`verify_<section>.m`)
After each solved quantity, check it before moving on. Use the full time dependence of the
signals (`dF1/dt = F1dot`, `dF1dot/dt = F1ddot`, ...).
- After `phi2`: the first bracket condition holds, `x1*TERM1 == -k1*x1^2`.
- After `phi3`: the second bracket condition holds.
- After `u`: the **full closed-loop check**: with `z2 = phi2 - X2`, `z3 = phi3 - X3`,
  `V = X1^2/2 + z2^2/2 + z3^2/2`, compute dV/dt by the chain rule along the real dynamics
  (with the derived `u`) and require
  `simplify(Vdot - (-k1*X1^2 - k2*z2^2 - k3*z3^2)) == 0`.
- Each derivative (`phi2_dot`, `phi3_dot`): compare with `diff` of the fully resolved
  expression along the dynamics; the difference must be 0.
- If a check fails: stop, find the missing or wrong term, report it, fix the derivation, re-run
  all checks. Never report a law whose closed-loop check is not 0.
- Every compact or short form that goes to Simulink (e.g. a law written with Vin as an input) is
  compared with the full expression by an assert; the difference must be 0.
- The closed-loop check proves only what V contains. When states stay outside V (internal
  dynamics, unknown parameters, a region where the law is singular), also run a simulation:
  choose initial conditions that test the claimed limits (inside and outside a stability region,
  both signs of a stability condition), report max |u| and warn about actuator saturation.
- Choose the ODE solver by the time scales. If the system is stiff (time constants far apart,
  e.g. an electrical L/R of milliseconds next to mechanical dynamics of seconds, or large
  adaptation gains), use `ode15s`, not `ode45`. Start with a short horizon (a few seconds) and
  state the solver and the reason in the report. A run that takes minutes is a sign of stiffness.

### B4. Simplification and 0/0
For `W_ref`, `i_ref` and the final law, at the abstract (`g_i`, `f_i`) and physical level:
- simplify (`simplifyFraction` for rational expressions, otherwise `simplify`; split if slow),
- list denominators of the final expression and of every intermediate definition
  (e.g. `J` in `g3 = K/J`),
- for each candidate variable `v`: evaluate the intermediate definitions step by step with test
  numbers at `v = 0` (may give NaN/Inf) and the simplified expression at the same point. NaN in
  the step-by-step evaluation but finite in the simplified one = removable singularity; infinite
  in both = real singularity. Compute `limit` (left and right if they can differ),
- test simplified vs unsimplified at 5 random points (`rng(42)`, `digits(50)`, values in
  `[0.5, 2]`): relative difference < 1e-10.

### B5. Outputs
- `results.mat`: every derived quantity, abstract and physical, simplified and unsimplified.
- Final law as text in the report and as a Simulink-ready function:
  ```matlab
  matlabFunction(Vin_simp, 'File', 'Vin_fun', 'Vars', {DV, W, i, Qvad, DP, Qvad_dot, DP_dot, Qvad_ddot, DP_ddot, ...}, 'Outputs', {'Vin'});
  ```
  The generated file splits the formula into temporaries named `t4`, `et1`, ...; these are not
  time and not `t1`/`t2` (τ1, τ2). Say this in README.md. List the input order in the report.
  Ask before choosing a different format.
- Last: write `README.md`, then move all check files into `checks/` and confirm that the
  top level holds only README, REPORT, the derivation, the Simulink function and results.

### B6. Compare with a reference (if the user provides one)
Only now open the reference code. Run a **copy** of it, then compare:
`simplify(Vin_agent - Vin_ref) == 0` (and the same for `W_ref`, `i_ref`). Run the closed-loop
check of B3 on the reference result as well. Report agreement or the exact difference term and
its cause.

### B7. Saving raw results
`diary` does not work reliably in this environment. Capture script output with
`txt = evalc('run(''verify_x.m'')');` and write it to `analysis_results.md`. Never delete or
edit earlier output blocks; append the new run below with a time stamp.

## Report (`REPORT.md`)
1. Document, scope, output folder, decisions taken (S-answers).
2. Errors found in the hand-solved part: equation, problem, corrected form, consequence.
3. Each step `T<n>`: what was done, result, verification result.
4. Final law: simplified form, required signals (e.g. second derivatives of Qvad and DP),
   assumptions (ω ≠ 0, ...), singularities and limits.
5. Code choices: one line each for the places where the code differs from the author's usual
   constructs (the same reasons as the code comments, collected in one place).
6. Reference comparison (if any).
7. External questions (for the author or others).
8. Files in the output folder, one line each.
