# word-equations-to-matlab

A Claude Code skill that turns a hand-written control derivation in Word into verified MATLAB code.

In our lab, control laws are designed in Word. The author solves the easy parts by hand and lists the remaining steps in plain words, for example "Choose V", "Solve for x2_ref and u", "Take derivative" and "Subs f and g". The document can also be much shorter: **the state equations alone are enough**. If there is no step list or no Lyapunov function, Claude proposes the standard backstepping steps and asks the user to confirm them (see example 01).

This skill has Claude:

1. **Check** the hand-solved part for sign errors, inconsistencies and invalid choices, such as a Lyapunov function that is not positive definite.
2. **Ask** the user every design decision the document leaves open, on a single question screen. These include the Lyapunov function, the error sign convention, the placement of cross terms, sign assumptions such as sgn(ω), and how adaptation laws are handled.
3. **Carry out** the remaining steps symbolically in MATLAB (Symbolic Math Toolbox), following the author's code style.
4. **Verify** every step, and finally the whole closed loop: V̇ along the true dynamics must equal the target, for example −Σkᵢzᵢ².
5. **Deliver** the final control law as MATLAB functions ready for Simulink (`Vin_fun.m`, adaptation laws), together with a report.

### At a glance

Input (example 03, abridged):

```
ẋ1 = x2 + θ1·x1²,  ẋ2 = x3 + θ2·x1·x2,  ẋ3 = θ3·x3 + u      θ1, θ2, θ3 unknown
Choose V = ½x1² + ½z2² + ½z3² + Σ θ̃i²/(2γi)
Solve for φ2, φ3 and u such that V̇ = −k1x1² − k2z2² − k3z3²
Choose the adaptation laws such that TERM_θi = 0
```

Output: a report, the derivation scripts, and Simulink-ready functions, e.g.

```
φ2   = −x1·(k1 + θ̂1·x1)
θ̂̇3  = −γ3·z3·x3
u    = u_fun(x1, x2, x3, th1h, th2h, th3h, k1, k2, k3, g1, g2, g3)   % 418-term polynomial
check: V̇ + k1x1² + k2z2² + k3z3² = 0  (symbolic, along the true dynamics)
```

Scope: backstepping-type derivations, including adaptive backstepping with tuning functions. The skill was developed and tested at the control systems workstation of the Physiological Control Laboratory (Yıldız Technical University).

## Requirements

- Claude Code
- MATLAB with Symbolic Math Toolbox (tested on R2025b), connected to Claude Code through the MATLAB MCP server from MathWorks' MATLAB Agentic Toolkit
- The `matlab-use-symbolic-math` skill from the MATLAB Agentic Toolkit (the skill tells Claude to use it for Symbolic Math Toolbox conventions)
- pandoc, which reads the .docx
- Simulink, only for the example Simulink test

## Install

Copy `skill/SKILL.md` to your Claude Code skills folder:

```
~/.claude/skills/word-equations-to-matlab/SKILL.md          (macOS / Linux)
C:\Users\<you>\.claude\skills\word-equations-to-matlab\SKILL.md   (Windows)
```

Restart Claude Code.

## Use

Open Claude Code in a folder that contains the Word document and call the skill by name. Automatic skill loading is not reliable, so naming it is safer:

```
/word-equations-to-matlab  Derive the control law in input_document.docx
```

The work happens in two phases:

- **Phase A (questions).** Claude extracts the document and checks the hand-solved part. It then asks its questions on one screen, each with a recommended answer. If a finding would change the derivation, it stops and asks before going further. The user stays in the loop here; nothing is derived until the user answers.
- **Phase B (derivation).** Claude writes and runs the MATLAB scripts. It always verifies each step and the full closed loop symbolically. When useful (adaptive laws, internal dynamics, stability regions) it also simulates the closed loop with ode45/ode15s. Then it writes the report.

Everything goes into a new folder, `<document>_model_<timestamp>/`:

| File | Content |
|---|---|
| `REPORT.md` | Decisions, errors found in the document, steps, final law, simulation, open questions for the author |
| `inventory.md` | Equations, symbols, the user's answers |
| `side_by_side.md` | The document's equations next to MATLAB's |
| `chk_document.m` | Checks of the hand-solved part |
| `deriv_*.m`, `verify_*.m` | Derivation and independent verification |
| `*_fun.m` | Simulink-ready functions (control law, adaptation laws) |
| `analysis_results.md` | Raw output of every script run, appended with timestamps |

Reports are written in the user's language. The example reports were partly written in Turkish and have been translated.

**Before wiring a function into Simulink, check its input order** in the first line of the `*_fun.m` file or in the report. Two runs on the same document can produce the same law with a different input order.

Each example folder has its own README with the questions Claude asked, the answers given, and which file to open first.

## Examples

| Folder | Document | What it shows |
|---|---|---|
| `examples/01_backstepping_pump` | Gear-pump model (3 states). Only the model is given: no step list, no Lyapunov function | The law matches the author's own solution (`author_reference_solution.m`) exactly. `simulink_test.m` builds a Simulink model and runs the law on the full pump model: ΔV goes from 2 mL to ~1e-11 mL. |
| `examples/02_adaptive_pump` | Adaptive section of the same document, with J and L unknown | Claude found 3 sign errors and a non-positive-definite V in the document. It also found that the document's adaptation law cannot prove stability, so it added a tuning-function term. It used ode15s for this stiff system. |
| `examples/03_adaptive_three_parameters` | Three unknown parameters, one in the first equation | Full tuning-function design. Simulation compares it with the plain certainty-equivalence laws, where V increases. |

## Testing

The skill was tested on 14 documents. The 3 hardest were then run twice more each to check repeatability. Finally, the skill was installed from this repository under a different Claude account and run on example 01; the result matched. Every result was verified independently: against the author's code, by an independent derivation, or by recomputing V̇ along the true dynamics. See [TESTING.md](TESTING.md).

## Limitations

- **The user must answer the design questions.** The skill does not choose the Lyapunov function or the sign assumptions alone, by design. The user needs to know enough control theory to answer.
- **Long chains give very large laws.** An 8-state chain gave a law of 4308 terms that needs the 6th derivative of an input signal. The report states which signal derivatives are needed. Obtaining them (analytically, or with filters or command-filtered backstepping) is left to the user.
- **The law is not tuned for real hardware.** Large initial control values are reported, but saturation is not part of the design. When the law divides by a parameter estimate θ̂, projection is recommended in the report but not built into the Simulink functions.
- **Only backstepping-type designs are covered.**
