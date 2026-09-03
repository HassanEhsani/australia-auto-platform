import AdminShell from "@/components/layout/admin-shell";

const stats = [
  { label: "Total Vehicles", value: "248", note: "+12 this week" },
  { label: "Customers", value: "1,842", note: "+38 this week" },
  { label: "Reservations", value: "24", note: "6 need review" },
  { label: "Sales", value: "67", note: "$1.48M this month" },
];

const alerts = [
  {
    title: "Vehicle interest alert",
    detail:
      "3 vehicles are receiving unusually high Not Interested feedback.",
  },
  {
    title: "CRM sync",
    detail: "Zoho CRM integration is not connected yet.",
  },
  {
    title: "Branch setup",
    detail:
      "Multi-branch permissions are pending customer confirmation.",
  },
];

const activity = [
  "Toyota RAV4 reservation created",
  "Customer profile updated",
  "BMW X3 added to inventory",
  "Ford Ranger marked as damaged stock",
];

export default function Home() {
  return (
    <AdminShell>
      <div className="space-y-6">
        <section className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
          {stats.map((stat) => (
            <article
              key={stat.label}
              className="rounded-2xl border border-[#dfe6ed] bg-white p-5"
            >
              <p className="text-sm font-semibold text-[#7a8da1]">
                {stat.label}
              </p>

              <div className="mt-3 text-3xl font-black text-[#123f68]">
                {stat.value}
              </div>

              <p className="mt-2 text-xs font-medium text-[#7a8da1]">
                {stat.note}
              </p>
            </article>
          ))}
        </section>

        <section className="grid gap-6 xl:grid-cols-[1.3fr_0.7fr]">
          <article className="rounded-2xl border border-[#dfe6ed] bg-white p-5">
            <p className="text-xs font-bold uppercase tracking-[0.16em] text-[#7a8da1]">
              Attention Required
            </p>

            <h3 className="mt-1 text-xl font-black text-[#123f68]">
              Alerts
            </h3>

            <div className="mt-5 space-y-3">
              {alerts.map((alert) => (
                <div
                  key={alert.title}
                  className="rounded-xl border border-[#e4e9ee] bg-[#f8fafc] p-4"
                >
                  <div className="text-sm font-black text-[#123f68]">
                    {alert.title}
                  </div>

                  <div className="mt-1 text-sm leading-6 text-[#6f8295]">
                    {alert.detail}
                  </div>
                </div>
              ))}
            </div>
          </article>

          <article className="rounded-2xl border border-[#dfe6ed] bg-white p-5">
            <p className="text-xs font-bold uppercase tracking-[0.16em] text-[#7a8da1]">
              Platform
            </p>

            <h3 className="mt-1 text-xl font-black text-[#123f68]">
              System Health
            </h3>

            <div className="mt-5 space-y-3">
              {[
                ["Backend API", "Running"],
                ["PostgreSQL", "Local"],
                ["Zoho CRM", "Pending"],
                ["Admin Web", "Running"],
              ].map(([label, status]) => (
                <div
                  key={label}
                  className="flex items-center justify-between rounded-xl bg-[#f8fafc] px-4 py-3"
                >
                  <span className="text-sm font-semibold text-[#587089]">
                    {label}
                  </span>

                  <span className="text-xs font-black text-[#123f68]">
                    {status}
                  </span>
                </div>
              ))}
            </div>
          </article>
        </section>

        <section className="rounded-2xl border border-[#dfe6ed] bg-white p-5">
          <p className="text-xs font-bold uppercase tracking-[0.16em] text-[#7a8da1]">
            Operations
          </p>

          <h3 className="mt-1 text-xl font-black text-[#123f68]">
            Recent Activity
          </h3>

          <div className="mt-5 divide-y divide-[#e8edf2]">
            {activity.map((item) => (
              <div key={item} className="flex gap-3 py-3">
                <div className="h-2.5 w-2.5 rounded-full bg-[#123f68]" />
                <span className="text-sm font-medium text-[#587089]">
                  {item}
                </span>
              </div>
            ))}
          </div>
        </section>
      </div>
    </AdminShell>
  );
}