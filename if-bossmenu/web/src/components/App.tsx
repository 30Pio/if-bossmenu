import { useBossmenu } from "../store/appStore";
import { debugData } from "../utils/debugData";
import { Transition } from '@mantine/core';
import Header from "./Header";
import Main from "./Main";
import { useNuiEvent } from "../hooks/useNuiEvent";
import Footer from "./Footer";
import { useLocalStorage } from "@mantine/hooks";

debugData([
  {
    action: "setVisible",
    data: true,
  },
]);


export default function App() {
  const [view, setShow, setPlayerData, setAccountData, setEmployeeData, setLocation, setBilldata] = useBossmenu((state) => [state.show, state.setShow, state.setPlayerData, state.setAccountData, state.setEmployeeData, state.setLocation, state.setBillData]);
  useNuiEvent("setVisible", (data: boolean) => {
    setShow(data);
  })
  useNuiEvent("SendPlayerData", (data: any) => {
    setPlayerData(data);
  })
  useNuiEvent("SetAccountData", (data: any) => {
    setAccountData(data);
  })
  useNuiEvent("SetEmployees", (data: any) => {
    setEmployeeData(data)
  })
  useNuiEvent("SetBills", (data: any) => {
    setBilldata(data);
    setLocation("clientbills");
  })

  const [background] = useLocalStorage({
    key: "background",
    defaultValue: "https://raw.githubusercontent.com/PH-Studios/static_assets/main/Group962.png",
  });

  return (
    <Transition
      mounted={view}
      transition="slide-up"
      duration={400}
      timingFunction="linear"
    >
      {(styles) => <div className="Home" style={{ ...styles, backgroundImage: `url(${background})`, backgroundRepeat: 'no-repeat' }}>
        <Header />
        <Main />
        <Footer />
      </div>}
    </Transition>
  )
}
