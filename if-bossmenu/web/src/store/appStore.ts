import { create } from "zustand";
import { immer } from "zustand/middleware/immer";

type PlayerJobData = {
  type?: string;
  name?: string;
  isboss?: boolean;
  label?: string;
  onduty?: boolean;
  grade?: {
    level?: number;
    name?: string;
    payment?: number;
    isboss?: boolean;
  };
};

type EmployeeData = {
  empSource?: string;
  isboss?: boolean;
  online?: boolean;
  name?: string;
  grade?: {
    isboss?: boolean;
    name?: string;
    level?: number;
    payment?: number;
  };
};

type BillData = {
  pdata?: {
    crypto?: number;
    bank?: number;
    cash?: number;
  };
  data?: SubBillData[];
};
type SubBillData = {
  fromname?: string;
  fromcitizenid?: string;
  toname?: string;
  tocitizenid?: string;
  rcdate?: string;
  untildate?: string;
  amount?: number;
  job?: string;
  id?: number;
};

type State = {
  show: boolean;
  playerData: PlayerJobData;
  accountData?: {
    id?: number;
    money?: number;
    job?: string;
  };
  location: string;
  employeeData: EmployeeData[];
  billdata?: BillData;
};

type Actions = {
  setShow(show: boolean): void;
  setPlayerData(playerData: PlayerJobData): void;
  setAccountData(accountData: { id: number; money: number; job: string }): void;
  setLocation(location: string): void;
  setEmployeeData(employeeData: EmployeeData[]): void;
  setBillData(billData: any): void;
};

export const useBossmenu = create<State & Actions>()(
  immer((set, get) => ({
    show: false,
    playerData: {},
    accountData: {},
    location: "",
    employeeData: [],
    billdata: [],
    setShow: (show) => set({ show }),
    setPlayerData: (playerData) => set({ playerData }),
    setAccountData: (accountData) => set({ accountData }),
    setLocation: (location) => set({ location }),
    setEmployeeData: (employeeData) => set({ employeeData }),
    setBillData: (billdata) => set({ billdata }),
  })),
);
