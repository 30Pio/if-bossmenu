import { useBossmenu } from "../store/appStore";

export default function Footer() {
    const [playerData, location] = useBossmenu((state) => [state.playerData, state.location]);
    return (
        <div style={{
            width: "75%",
            height: "5vh",
            display: "flex",
            justifyContent: "start",
            alignItems: "center",
        }}>
            
            {location !== 'clientbills' && <><svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M7 0L9.32638 4.67362L14 7L9.32638 9.32638L7 14L4.67362 9.32638L0 7L4.67362 4.67362L7 0Z" fill="white" />
            </svg><div style={{ marginLeft: '0.5vw' }}>Business: {playerData?.label}</div></>}
        </div>
    )
}