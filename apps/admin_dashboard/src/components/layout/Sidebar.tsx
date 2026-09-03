const menu = [
  "Dashboard",
  "Vehicles",
  "Customers",
  "Reservations",
  "Sales",
  "Alerts",
  "Not Interested",
  "Reports",
  "Analytics",
  "Branches",
  "Users",
  "Roles",
  "Settings",
];


export default function Sidebar() {

  return (
    <aside className="hidden min-h-screen w-64 bg-[#101923] px-5 py-6 text-white lg:block">

      <div className="mb-10">

        <div className="text-lg font-black tracking-wide">
          👑 KING AUTO
        </div>

      </div>


      <nav className="space-y-2">

        {menu.map((item,index)=>(

          <div
            key={item}
            className={`
              rounded-xl px-4 py-3 text-sm font-semibold
              ${
                index === 1
                ? "bg-[#1464d8] text-white"
                : "text-gray-300 hover:bg-white/10"
              }
            `}
          >
            {item}
          </div>

        ))}

      </nav>


      <div className="absolute bottom-5 text-xs text-gray-400">
        © King Auto
      </div>

    </aside>
  );
}
