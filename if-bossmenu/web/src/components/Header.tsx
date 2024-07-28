import { Button, Modal, NumberInput } from "@mantine/core";
import { useBossmenu } from "../store/appStore";
import { fetchNui } from "../utils/fetchNui";
import { useEffect, useState } from "react";
import { TextInput } from "@mantine/core";
import { notifications } from "@mantine/notifications";

export default function Header() {
    const [accountData, playerData, setLocation, location, billData, setBillData] = useBossmenu((state) => [state.accountData, state.playerData, state.setLocation, state.location, state.billdata, state.setBillData]);
    const [opened, setOpened] = useState(false);
    const [type, setType] = useState<string>('');
    const [amount, setAmount] = useState<number | undefined>(0); // Use the correct state type


    return (
        <div style={{
            width: "75%",
            height: "5vh",
            display: "flex",
            justifyContent: "center",
            alignItems: "center",
        }}>
            <div style={{
                display: "flex",
                flexDirection: 'row',
                justifyContent: "space-between",
                alignItems: "center",
                height: "100%",
                alignContent: "center",
                width: "100%",
            }}>
                <div style={{ lineHeight: '1.9vh', }}>
                    <div style={{
                        display: "flex",
                        flexDirection: 'row',
                        alignItems: "center",
                        marginLeft: '-0.6vw',
                    }}>
                        <svg style={{
                            width: '2.094vw',
                            height: '2.086vh',
                        }} viewBox="0 0 21 19" fill="none" xmlns="http://www.w3.org/2000/svg">
                            <path d="M10.5 0L13.8945 5.82793L20.4861 7.25532L15.9924 12.2846L16.6717 18.9947L10.5 16.275L4.32825 18.9947L5.00765 12.2846L0.513906 7.25532L7.10554 5.82793L10.5 0Z" fill="white" />
                        </svg>
                        <div className="text" style={{
                            fontWeight: 700,
                            marginTop: '0.4vh',
                            fontSize: '2.5vh',
                        }}>DIAMOND BOSSMENU</div>
                    </div>
                    <div>
                        <div className="text" style={{
                            marginTop: '0.4vh',
                        }}>Here you can build up and manage your business!</div>
                    </div>
                </div>
                <div style={{
                    display: "flex",
                    flexDirection: 'row',
                    alignItems: "center",
                    marginLeft: '-0.6vw',
                }}>
                    {location === 'clientbills' ? <>
                        <div className="midBut1" style={{
                            width:'auto',
                            padding: '0.5vh 0.7vw',
                            fontWeight: 700,
                            marginRight: '0.2vw',
                        }}>Cash : ${billData?.pdata.cash}</div>
                        <div className="midBut1" style={{
                            width:'auto',
                            padding: '0.5vh 0.7vw',
                            fontWeight: 700,
                            marginRight: '0.2vw',
                        }}>Bank Account : ${billData?.pdata.bank}</div>
                    </> : <><div className="midBut1">Society : {accountData?.money}</div>
                        <div className="midBut2" onClick={() => {
                            setOpened(true);
                            setType('withdraw');
                        }}>Withdraw</div>
                        <div className="midBut3" onClick={() => {
                            setOpened(true);
                            setType('deposit');
                        }}>Deposit</div>
                        <div className="midBut4" onClick={() => {
                            setLocation('manageBills');
                            fetchNui('GetBills').then((res) => {
                                setBillData(res);
                            });
                        }}>Manage Bills</div></>}
                </div>
                <div style={{
                    display: "flex",
                    flexDirection: 'row',
                    alignItems: "center",
                    marginLeft: '-0.6vw',
                    marginRight: '2.2vw',
                }} >
                    {location !== '' && location !== 'clientbills' ? <div className="midBut2" onClick={() => { setLocation('') }}>Back</div> : <></>}
                    <div className="midBut5" onClick={() => { fetchNui('hideFrame', false); setLocation('') }}>{location === 'clientbills' ? 'EXIT INVOICES': 'EXIT BOSS MENU'}</div>
                </div>
            </div>
            <Modal opened={opened} onClose={() => {
                setOpened(false);
            }} styles={{ content: { backgroundColor: 'rgba(255,255,255,1)' }, header: { backgroundColor: 'rgba(255,255,255,0.0)' }, overlay: { backgroundColor: 'rgba(255,255,255,0.0)' } }} title={type === 'withdraw' ? 'Withdraw' : 'Deposit'}>
                <TextInput
                    label="Amount"
                    placeholder="Enter amount"
                    type="number"
                    value={amount}
                    onChange={(event) => setAmount(parseInt(event.currentTarget.value))}
                />
                <Button onClick={() => {
                    fetchNui(type, { job: playerData.name, amount: amount }).then((res) => {
                        console.log(res);
                        if (res) {
                            notifications.show({
                                title: 'Success',
                                message: `Successfully ${type}ed ${amount} from ${playerData.name}`,
                                color: 'green',
                                autoClose: 5000,
                            })
                        } else {
                            notifications.show({
                                title: 'Failed',
                                message: `Failed to ${type} ${amount} from ${playerData.name}`,
                                color: 'red',
                                autoClose: 5000,
                            })
                        }
                    });
                    setOpened(false);
                }} style={{ marginTop: '1vh' }} color="red">Confirm</Button>
            </Modal>
        </div>
    )
}
