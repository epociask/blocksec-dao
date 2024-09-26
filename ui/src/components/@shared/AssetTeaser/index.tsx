import React, {ReactElement, useState} from 'react';
import Link from 'next/link';
import Dotdotdot from 'react-dotdotdot';
import NetworkName from '@shared/NetworkName';
import styles from './index.module.css';
import Modal from "@shared/atoms/Modal";
import {UserRoleTitle} from "../../../@types/user";

export declare type AssetTeaserProps = {
    name: string,
    type: string,
    description: string,
    bountyOwner: string,
    bountyAddress: string,
    bountyTitle: string,
    chainId: number,
    id: number,
    userRole: string
}

function getBountyDescription(bountyAddress: string) {

}

export default function AssetTeaser({
                                        id,
                                        chainId,
                                        name,
                                        type,
                                        description,
                                        bountyOwner,
                                        bountyAddress,
                                        bountyTitle,
                                        userRole
                                    }: AssetTeaserProps): ReactElement {
    const [isBountyOpen, setIsBountyOpen] = useState(false);
    let explorerAddress: string = "https://mumbai.polygonscan.com/address/" + bountyAddress;

    return (
        <article className={`${styles.teaser} ${styles[type]}`}>
            {/*<Link href={`/asset/${id}`}>*/}
            <a className={styles.link}>
                <aside className={styles.detailLine}>
                    <NetworkName
                        networkId={chainId}
                        className={styles.typeLabel}
                    />
                    <div className={styles.typeLabel}>
                        {bountyTitle}
                    </div>
                </aside>
                <header className={styles.header}>
                    <Dotdotdot tagName="h1" clamp={3} className={styles.title}>
                        {name.slice(0, 200)}
                    </Dotdotdot>
                </header>
                <footer className={styles.footer}>
            <span className={styles.typeLabel}>
              {(userRole === UserRoleTitle.Hacker) && <Link href={`/publish/1?address=${bountyAddress}`}>
                  <a className={styles.teaser}>Submit Vuln&nbsp;</a>
              </Link>}
                <Link href="#">
                <a className={styles.teaser} onClick={(event) => {
                    event.preventDefault();
                    setIsBountyOpen(true);
                }}>
                  {(userRole === UserRoleTitle.Hacker) && "| "}Explore Bounty
                </a>
              </Link>
              <Modal
                  title={"Explore Bounty"}
                  isOpen={isBountyOpen}
                  onToggleModal={() => setIsBountyOpen(false)}
              >

              <h1>
              {name}
              </h1>
              <p>
              {description}
              </p>

              <p>
                Bounty Address: <a href={explorerAddress}>{bountyAddress}</a>
              </p>
              <p>
                Bounty Owner: <a href={explorerAddress}>{bountyOwner}</a>
              </p>

              </Modal>
            </span>
                    <span className={styles.typeLabel}/>
                </footer>
            </a>
            {/*</Link>*/}
        </article>
    )
}
