import Header from "./header";
import Sidebar from "./Sidebar";

export default function AdminShell({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <main className="min-h-screen bg-[#f3f6f9] text-[#102f4f]">

      <div className="flex min-h-screen">

        <Sidebar />


        <section className="flex-1">

          <Header />


          <div className="p-6 md:p-10">
            {children}
          </div>


        </section>

      </div>

    </main>
  );
}
