"""Business-case calculator: NPV, IRR, ROI, payback, discounted payback, sensitivity.

No third-party dependencies. Two ways to use it:

1) Quick mode (net cash flows):
   python fin_calc.py --investment 80000 --flows 15000 30000 45000 50000 50000 --rate 0.11
   python fin_calc.py ... --sens rate=0.08,0.14 flows=0.7,1.2 investment=0.8,1.3

   --flows are net cash flows for years 1..N; --investment is the year-0 outflow (positive number).
   --sens flexes: rate=<absolute values>, flows/benefits/costs/investment=<multipliers>.

2) Spec mode (separate benefit and cost lines, ramp-up, scenarios):
   python fin_calc.py --spec model.json [--out result.json]

   model.json:
   {
     "unit": "Rp juta",
     "rate": 0.11,
     "years": 5,
     "investment": [{"name": "Platform build", "amount": 50000, "year": 0},
                    {"name": "Integration", "amount": 30000, "year": 1}],
     "costs":    [{"name": "Run cost", "annual": 6000, "growth": 0.05}],
     "benefits": [{"name": "Downtime avoided", "annual": 60000, "ramp": [0.25, 0.6, 0.9, 1, 1]},
                  {"name": "Engineer hours", "annual": 12000, "ramp": [0.3, 0.7, 1]}],
     "scenarios": {"conservative": {"benefits": 0.7, "costs": 1.2, "investment": 1.3},
                   "optimistic":   {"benefits": 1.2}}
   }
   "annual" = steady-state value per year; "ramp" = adoption share by year (last value repeats);
   "growth" = yearly escalation. Benefits/costs start at year 1; investment can be in any year.
   For each scenario and for a ±20% tornado on each line, the script reports NPV/IRR/payback.
"""
import argparse
import json
import sys


def npv(rate, flows):
    """flows[0] is year 0."""
    return sum(cf / (1 + rate) ** t for t, cf in enumerate(flows))


def irr(flows, lo=-0.99, hi=10.0, tol=1e-7):
    f_lo, f_hi = npv(lo, flows), npv(hi, flows)
    if f_lo * f_hi > 0:
        return None  # no sign change: IRR undefined in range
    for _ in range(300):
        mid = (lo + hi) / 2
        f_mid = npv(mid, flows)
        if abs(f_mid) < tol:
            return mid
        if f_lo * f_mid < 0:
            hi, f_hi = mid, f_mid
        else:
            lo, f_lo = mid, f_mid
    return (lo + hi) / 2


def payback(flows, rate=None):
    """Years until cumulative (optionally discounted) cash flow turns >= 0, interpolated."""
    cum = 0.0
    for t, cf in enumerate(flows):
        v = cf / (1 + rate) ** t if rate is not None else cf
        prev = cum
        cum += v
        if cum >= 0 and t > 0 and prev < 0:
            return t - 1 + (-prev / v if v else 0)
    return None if cum < 0 else 0.0


def metrics(flows, rate, gross=None):
    """gross = (total_benefits, total_costs_incl_investment); otherwise ROI uses net flows."""
    if gross:
        inflow, outflow = gross
    else:
        outflow = -sum(cf for cf in flows if cf < 0)
        inflow = sum(cf for cf in flows if cf > 0)
    return {
        "npv": npv(rate, flows),
        "irr": irr(flows),
        "roi": (inflow - outflow) / outflow if outflow else None,  # undiscounted
        "payback_years": payback(flows),
        "discounted_payback_years": payback(flows, rate),
        "flows": flows,
    }


def build_flows(spec, mult=None):
    mult = mult or {}
    years = spec["years"]
    flows = [0.0] * (years + 1)
    detail = {}
    tot_b = tot_c = 0.0
    for inv in spec.get("investment", []):
        a = inv["amount"] * mult.get("investment", 1) * mult.get(inv["name"], 1)
        flows[inv.get("year", 0)] -= a
        tot_c += a
    for kind, sign in (("benefits", 1), ("costs", -1)):
        for line in spec.get(kind, []):
            ramp = line.get("ramp", [1])
            g = line.get("growth", 0)
            row = []
            for y in range(1, years + 1):
                share = ramp[min(y - 1, len(ramp) - 1)]
                v = line["annual"] * share * (1 + g) ** (y - 1)
                v *= mult.get(kind, 1) * mult.get(line["name"], 1)
                flows[y] += sign * v
                if sign > 0:
                    tot_b += v
                else:
                    tot_c += v
                row.append(round(v, 2))
            detail[line["name"]] = row
    return flows, detail, (tot_b, tot_c)


def fmt(x, pct=False):
    if x is None:
        return "n/a"
    return f"{x * 100:.1f}%" if pct else f"{x:,.1f}"


def print_row(label, m):
    print(f"{label:<28} NPV {fmt(m['npv']):>14} | IRR {fmt(m['irr'], True):>8} | ROI {fmt(m['roi'], True):>8} "
          f"| Payback {fmt(m['payback_years']):>5} y | Disc. payback {fmt(m['discounted_payback_years']):>5} y")


def run_spec(path, out):
    spec = json.load(open(path, encoding="utf-8"))
    rate = spec["rate"]
    unit = spec.get("unit", "")
    result = {"unit": unit, "rate": rate}
    flows, detail, gross = build_flows(spec)
    base = metrics(flows, rate, gross)
    result["base"] = base
    result["line_detail"] = detail
    print(f"Unit: {unit} | discount rate {rate:.1%} | horizon {spec['years']} y")
    print("Net flows (y0..yN):", [round(f, 1) for f in flows])
    print_row("BASE", base)
    result["scenarios"] = {}
    for name, mult in spec.get("scenarios", {}).items():
        r = mult.get("rate", rate)
        f, _, g = build_flows(spec, mult)
        m = metrics(f, r, g)
        result["scenarios"][name] = m
        print_row(name, m)
    print("\nTornado (each line +/-20%, NPV swing):")
    names = [i["name"] for i in spec.get("investment", [])] + [l["name"] for k in ("benefits", "costs") for l in spec.get(k, [])]
    tornado = []
    for n in dict.fromkeys(names):
        lo = npv(rate, build_flows(spec, {n: 0.8})[0])
        hi = npv(rate, build_flows(spec, {n: 1.2})[0])
        tornado.append({"driver": n, "npv_at_-20%": lo, "npv_at_+20%": hi, "swing": abs(hi - lo)})
    lo_r, hi_r = npv(rate - 0.03, flows), npv(rate + 0.03, flows)
    tornado.append({"driver": "discount rate +/-3pp", "npv_at_-3pp": lo_r, "npv_at_+3pp": hi_r, "swing": abs(lo_r - hi_r)})
    tornado.sort(key=lambda d: -d["swing"])
    for d in tornado:
        print(f"  {d['driver']:<26} swing {fmt(d['swing']):>14}")
    result["tornado"] = tornado
    if out:
        json.dump(result, open(out, "w", encoding="utf-8"), indent=2)
        print(f"\nSaved {out}")


def run_quick(a):
    flows = [-a.investment] + a.flows
    print_row("BASE", metrics(flows, a.rate))
    for s in a.sens or []:
        key, vals = s.split("=")
        for v in map(float, vals.split(",")):
            if key == "rate":
                print_row(f"rate={v:.1%}", metrics(flows, v))
            elif key == "investment":
                print_row(f"investment x{v}", metrics([-a.investment * v] + a.flows, a.rate))
            elif key in ("flows", "benefits"):
                print_row(f"flows x{v}", metrics([-a.investment] + [f * v for f in a.flows], a.rate))
            else:
                sys.exit(f"unknown sensitivity key: {key}")


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--spec")
    p.add_argument("--out")
    p.add_argument("--investment", type=float)
    p.add_argument("--flows", type=float, nargs="+")
    p.add_argument("--rate", type=float, default=0.10)
    p.add_argument("--sens", nargs="*")
    a = p.parse_args()
    if a.spec:
        run_spec(a.spec, a.out)
    elif a.investment is not None and a.flows:
        run_quick(a)
    else:
        p.print_help()
