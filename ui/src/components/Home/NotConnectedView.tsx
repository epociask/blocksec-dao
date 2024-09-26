import React, {useEffect, useState} from "react";
import {useWeb3} from '@context/Web3'
import styles from "./index.module.css";
import Loader from "@shared/atoms/Loader";
import CompanyTeaser from "@shared/CompanyTeaser";
import IconCog from "@images/cog.svg";


export default function NotConnectedView() {

    const {accountId} = useWeb3();


    return (
        <>
            {!accountId ?
                <section className={styles.section}>
                    <h4>
                        <br/>
                        <br/>
                        <br/>
                        <br/>
                        Please connect your wallet for the awesome content here........
                        <br/>
                        <br/>
                        Wanna create a company with us, just hit us up at you know where.
                    </h4>
                </section> : <></>}
        </>
    )
}